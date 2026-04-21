param(
  [ValidateSet('start','stop','status')]
  [string]$Action = 'start',
  [int]$BackendPort = 8080,
  [int]$FrontendPort = 8082,
  [int]$ProxyPort = 8090,
  [string]$FrontendRoot = '',
  [switch]$Open
)

$ErrorActionPreference = 'Stop'

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendRoot = (Resolve-Path (Join-Path $ScriptRoot '..\..')).Path
if ([string]::IsNullOrWhiteSpace($FrontendRoot)) {
  $FrontendRoot = (Resolve-Path (Join-Path $BackendRoot '..\pop-master')).Path
}

$RuntimeRoot = Join-Path $BackendRoot 'runtime\cloudflare'
$StatePath = Join-Path $RuntimeRoot 'state.json'
$CloudflaredOutLog = Join-Path $RuntimeRoot 'cloudflared.out.log'
$CloudflaredErrLog = Join-Path $RuntimeRoot 'cloudflared.err.log'
$ProxyOutLog = Join-Path $RuntimeRoot 'proxy.out.log'
$ProxyErrLog = Join-Path $RuntimeRoot 'proxy.err.log'
$FrontendOutLog = Join-Path $RuntimeRoot 'frontend.out.log'
$FrontendErrLog = Join-Path $RuntimeRoot 'frontend.err.log'
$ToolsRoot = Join-Path $env:USERPROFILE '.codex\tools\cloudflared'
$CloudflaredPath = Join-Path $ToolsRoot 'cloudflared.exe'
$TryCloudflarePattern = 'https?://[a-z0-9-]+\.trycloudflare\.com'

function Write-Step([string]$Message) {
  Write-Output "[POP Cloudflare] $Message"
}

function Read-State {
  if (!(Test-Path -LiteralPath $StatePath)) { return $null }
  try { return Get-Content -LiteralPath $StatePath -Raw | ConvertFrom-Json } catch { return $null }
}

function Write-State([hashtable]$Payload) {
  New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
  $Payload.updatedAt = (Get-Date).ToString('s')
  $Payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $StatePath -Encoding UTF8
}

function Test-Listening([int]$Port) {
  return [bool](Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1)
}

function Get-ListenerPid([int]$Port) {
  $listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($listener) { return [int]$listener.OwningProcess }
  return 0
}

function Stop-Pid([int]$ProcessId) {
  if ($ProcessId -le 0) { return }
  $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
  if ($process) { Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue }
}

function Get-StateInt($State, [string]$Name) {
  if (!$State) { return 0 }
  $property = $State.PSObject.Properties[$Name]
  if (!$property -or $null -eq $property.Value) { return 0 }
  return [int]$property.Value
}

function Stop-CurrentState {
  $state = Read-State
  if ($state) {
    Stop-Pid (Get-StateInt $state 'cloudflaredPid')
    Stop-Pid (Get-StateInt $state 'proxyPid')
    Stop-Pid (Get-StateInt $state 'frontendPid')
  }
  $proxyPid = Get-ListenerPid $ProxyPort
  if ($proxyPid) { Stop-Pid $proxyPid }
  Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object {
      ($_.CommandLine -match 'cloudflared' -and $_.CommandLine -match "127\.0\.0\.1:$ProxyPort") -or
      ($_.CommandLine -match 'pop-cloudflare-proxy\.mjs')
    } |
    ForEach-Object { Stop-Pid ([int]$_.ProcessId) }
}

function Ensure-Cloudflared {
  $pathBinary = (Get-Command cloudflared -ErrorAction SilentlyContinue)
  if ($pathBinary) { return $pathBinary.Source }
  if (Test-Path -LiteralPath $CloudflaredPath) { return $CloudflaredPath }

  New-Item -ItemType Directory -Force -Path $ToolsRoot | Out-Null
  $url = 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe'
  Write-Step "Téléchargement de cloudflared"
  Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $CloudflaredPath
  return $CloudflaredPath
}

function Ensure-MariaDb {
  if (Test-Listening 3306) { return }
  $mariaBase = Join-Path $env:USERPROFILE '.codex\tools\mariadb-10.11.16-winx64'
  $dataDir = Join-Path $env:USERPROFILE '.codex\tools\mariadb-data-pop-backend-main'
  $server = Join-Path $mariaBase 'bin\mariadbd.exe'
  $config = Join-Path $dataDir 'my.ini'
  if (!(Test-Path -LiteralPath $server) -or !(Test-Path -LiteralPath $config)) {
    throw 'MariaDB local est introuvable. Lancez d’abord la mise en place DB du projet.'
  }
  Write-Step "Démarrage MariaDB"
  Start-Process -FilePath $server -ArgumentList @("--defaults-file=$config","--bind-address=127.0.0.1") -WorkingDirectory $mariaBase -WindowStyle Hidden | Out-Null
  Start-Sleep -Seconds 5
  if (!(Test-Listening 3306)) { throw 'MariaDB n’a pas ouvert le port 3306.' }
}

function Ensure-Backend {
  if (Test-Listening $BackendPort) { return }
  $javaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME','User')
  if ([string]::IsNullOrWhiteSpace($javaHome)) {
    $javaHome = Join-Path $env:USERPROFILE '.codex\tools\jdk8\jdk8u482-b08'
  }
  $java = Join-Path $javaHome 'bin\javaw.exe'
  $war = Join-Path $BackendRoot 'target\app-server-1.0.0.war'
  if (!(Test-Path -LiteralPath $java)) { throw "Java 8 introuvable: $java" }
  if (!(Test-Path -LiteralPath $war)) {
    Write-Step "Build backend"
    $env:JAVA_HOME = $javaHome
    $env:Path = "$javaHome\bin;$env:Path"
    Push-Location $BackendRoot
    try { & .\mvnw.cmd -q -DskipTests package } finally { Pop-Location }
    if ($LASTEXITCODE -ne 0) { throw 'Build backend échoué.' }
  }

  $env:POP_DB_URL = [Environment]::GetEnvironmentVariable('POP_DB_URL','User')
  $env:POP_DB_USERNAME = [Environment]::GetEnvironmentVariable('POP_DB_USERNAME','User')
  $env:POP_DB_PASSWORD = [Environment]::GetEnvironmentVariable('POP_DB_PASSWORD','User')
  $env:POP_SECURITY_USER = [Environment]::GetEnvironmentVariable('POP_SECURITY_USER','User')
  $env:POP_SECURITY_PASSWORD = [Environment]::GetEnvironmentVariable('POP_SECURITY_PASSWORD','User')

  Write-Step "Démarrage backend"
  Start-Process -FilePath $java -ArgumentList @('-jar', $war) -WorkingDirectory $BackendRoot -WindowStyle Hidden | Out-Null
  Start-Sleep -Seconds 12
  if (!(Test-Listening $BackendPort)) { throw "Backend indisponible sur le port $BackendPort." }
}

function Start-Proxy {
  $existingPid = Get-ListenerPid $ProxyPort
  if ($existingPid) { Stop-Pid $existingPid; Start-Sleep -Seconds 1 }
  $node = (Get-Command node -ErrorAction Stop).Source
  $proxyScript = Join-Path $ScriptRoot 'pop-cloudflare-proxy.mjs'
  $env:POP_PROXY_PORT = [string]$ProxyPort
  $env:POP_FRONTEND_PORT = [string]$FrontendPort
  $env:POP_BACKEND_PORT = [string]$BackendPort
  Write-Step "Démarrage proxy local"
  $process = Start-Process -FilePath $node -ArgumentList @($proxyScript) -WorkingDirectory $BackendRoot -RedirectStandardOutput $ProxyOutLog -RedirectStandardError $ProxyErrLog -WindowStyle Hidden -PassThru
  Start-Sleep -Seconds 2
  if (!(Test-Listening $ProxyPort)) { throw "Proxy local indisponible sur le port $ProxyPort." }
  return $process.Id
}

function Start-Cloudflared([string]$Cloudflared) {
  if (Test-Path -LiteralPath $CloudflaredOutLog) { Remove-Item -LiteralPath $CloudflaredOutLog -Force }
  if (Test-Path -LiteralPath $CloudflaredErrLog) { Remove-Item -LiteralPath $CloudflaredErrLog -Force }
  Write-Step "Ouverture tunnel Cloudflare"
  $process = Start-Process -FilePath $Cloudflared -ArgumentList @('tunnel','--url',"http://127.0.0.1:$ProxyPort",'--no-autoupdate') -WorkingDirectory $RuntimeRoot -RedirectStandardOutput $CloudflaredOutLog -RedirectStandardError $CloudflaredErrLog -WindowStyle Hidden -PassThru

  $deadline = (Get-Date).AddSeconds(45)
  do {
    Start-Sleep -Milliseconds 500
    $text = ''
    if (Test-Path -LiteralPath $CloudflaredOutLog) {
      $text += Get-Content -LiteralPath $CloudflaredOutLog -Raw -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $CloudflaredErrLog) {
      $text += "`n"
      $text += Get-Content -LiteralPath $CloudflaredErrLog -Raw -ErrorAction SilentlyContinue
    }
    if ($text) {
      $match = [regex]::Match($text, $TryCloudflarePattern)
      if ($match.Success) {
        return @{ pid = $process.Id; url = $match.Value }
      }
    }
    if ($process.HasExited) { throw 'cloudflared s’est terminé avant de fournir une URL.' }
  } while ((Get-Date) -lt $deadline)

  throw 'cloudflared n’a pas fourni d’URL dans le délai imparti.'
}

function Start-Frontend([string]$PublicUrl) {
  $existingPid = Get-ListenerPid $FrontendPort
  if ($existingPid) { Stop-Pid $existingPid; Start-Sleep -Seconds 3 }
  if (!(Test-Path -LiteralPath $FrontendRoot)) { throw "Front introuvable: $FrontendRoot" }
  $env:EXPO_PUBLIC_POP_API_ORIGIN = $PublicUrl
  $env:EXPO_PUBLIC_POP_API_BASIC_AUTH = 'user:password'
  Write-Step "Démarrage front Expo avec API publique"
  $process = Start-Process -FilePath 'npm.cmd' -ArgumentList @('run','web','--','--port',"$FrontendPort",'--host','localhost') -WorkingDirectory $FrontendRoot -RedirectStandardOutput $FrontendOutLog -RedirectStandardError $FrontendErrLog -WindowStyle Hidden -PassThru
  Start-Sleep -Seconds 15
  if (!(Test-Listening $FrontendPort)) { throw "Front indisponible sur le port $FrontendPort." }
  return $process.Id
}

function Show-Status {
  $state = Read-State
  if (!$state) {
    Write-Output 'Aucun tunnel POP Cloudflare connu.'
    return
  }
  $active = $false
  $cloudflaredPid = Get-StateInt $state 'cloudflaredPid'
  if ($cloudflaredPid -gt 0) {
    $active = [bool](Get-Process -Id $cloudflaredPid -ErrorAction SilentlyContinue)
  }
  Write-Output "Actif: $active"
  Write-Output "URL: $($state.url)"
  Write-Output "Proxy: http://127.0.0.1:$ProxyPort"
  Write-Output "Backend: http://127.0.0.1:$BackendPort"
  Write-Output "Front: http://127.0.0.1:$FrontendPort"
}

if ($Action -eq 'stop') {
  Stop-CurrentState
  Write-State @{ active = $false; url = ''; cloudflaredPid = 0; proxyPid = 0; frontendPid = 0 }
  Write-Step 'Tunnel arrêté'
  exit 0
}

if ($Action -eq 'status') {
  Show-Status
  exit 0
}

New-Item -ItemType Directory -Force -Path $RuntimeRoot | Out-Null
Stop-CurrentState
Ensure-MariaDb
Ensure-Backend
$proxyPid = Start-Proxy
$cloudflared = Ensure-Cloudflared
$tunnel = Start-Cloudflared $cloudflared
$frontendPid = Start-Frontend $tunnel.url

Write-State @{
  active = $true
  url = $tunnel.url
  cloudflaredPid = $tunnel.pid
  proxyPid = $proxyPid
  frontendPid = $frontendPid
  backendPort = $BackendPort
  frontendPort = $FrontendPort
  proxyPort = $ProxyPort
}

Write-Output ''
Write-Output "POP_PUBLIC_URL=$($tunnel.url)"
Write-Output "Admin: admin / admin"
Write-Output ''

if ($Open) {
  Start-Process $tunnel.url | Out-Null
}
