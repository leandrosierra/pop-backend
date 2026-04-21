[CmdletBinding()]
param(
  [ValidateSet('', 'dev', 'uat', 'prod', 'all')]
  [string]$Env = '',
  [ValidateSet('menu', 'status', 'start', 'stop', 'restart', 'full', 'build', 'seed', 'logs', 'promote')]
  [string]$Action = 'menu',
  [switch]$Open,
  [switch]$Seed,
  [int]$HealthcheckTimeoutSec = 45
)

$ErrorActionPreference = 'Stop'

try { [Console]::OutputEncoding = [Text.UTF8Encoding]::new() } catch {}

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendRoot = (Resolve-Path (Join-Path $ScriptRoot '..\..')).Path
$WorkspaceRoot = (Resolve-Path (Join-Path $BackendRoot '..')).Path
$FrontendRoot = Join-Path $WorkspaceRoot 'pop-master'
$ConfigPath = Join-Path $BackendRoot 'config\deploy-environments.json'
$RuntimeRoot = Join-Path $BackendRoot 'runtime\deploy'
$WarSource = Join-Path $BackendRoot 'target\app-server-1.0.0.war'
$ProxyScript = Join-Path $ScriptRoot 'pop-local-proxy.mjs'
$EnvOrder = @('dev', 'uat', 'prod')

function Step([string]$Message) {
  Write-Host "[POP Deploy] $Message" -ForegroundColor Cyan
}

function Ok([string]$Message) {
  Write-Host "[OK] $Message" -ForegroundColor Green
}

function Warn([string]$Message) {
  Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Fail([string]$Message) {
  Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Read-JsonFile([string]$Path) {
  return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-EnvConfig([string]$Key) {
  $config = Read-JsonFile $ConfigPath
  $property = $config.environments.PSObject.Properties[$Key]
  if (!$property) { throw "Environnement inconnu: $Key" }
  $entry = $property.Value
  $apiOriginProperty = $entry.PSObject.Properties['apiOrigin']
  $apiOrigin = if ($apiOriginProperty -and $apiOriginProperty.Value) { [string]$apiOriginProperty.Value } else { "http://localhost:$([int]$entry.backendPort)" }
  return [pscustomobject]@{
    Key          = $Key
    Label        = [string]$entry.label
    BackendPort  = [int]$entry.backendPort
    FrontendPort = [int]$entry.frontendPort
    ProxyPort    = [int]$entry.proxyPort
    PromoteTo    = if ($entry.promoteTo) { [string]$entry.promoteTo } else { $null }
    ApiOrigin    = $apiOrigin
    FrontendUrl  = "http://localhost:$([int]$entry.frontendPort)"
    ProxyUrl     = "http://localhost:$([int]$entry.proxyPort)"
  }
}

function Get-TargetEnvs {
  if ($Env -eq 'all' -or [string]::IsNullOrWhiteSpace($Env)) {
    if ($Action -eq 'menu') { return @() }
    return $EnvOrder
  }
  return @($Env)
}

function Get-StatePath($EnvConfig) {
  return Join-Path $RuntimeRoot "$($EnvConfig.Key)\state.json"
}

function Get-LogRoot($EnvConfig) {
  return Join-Path $RuntimeRoot "$($EnvConfig.Key)\logs"
}

function Read-State($EnvConfig) {
  $path = Get-StatePath $EnvConfig
  if (!(Test-Path -LiteralPath $path)) { return $null }
  try { return Read-JsonFile $path } catch { return $null }
}

function Write-State($EnvConfig, [hashtable]$Payload) {
  $statePath = Get-StatePath $EnvConfig
  $parent = Split-Path $statePath -Parent
  New-Item -ItemType Directory -Force -Path $parent | Out-Null
  $Payload.updatedAt = (Get-Date).ToString('s')
  $Payload | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8
}

function Get-StateInt($State, [string]$Name) {
  if (!$State) { return 0 }
  $property = $State.PSObject.Properties[$Name]
  if (!$property -or $null -eq $property.Value) { return 0 }
  try { return [int]$property.Value } catch { return 0 }
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
  if ($process) {
    Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
  }
}

function Stop-Port([int]$Port) {
  $listenerPid = Get-ListenerPid $Port
  if ($listenerPid -gt 0) {
    Stop-Pid $listenerPid
    Start-Sleep -Milliseconds 700
  }
}

function Resolve-JavaHome {
  $javaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User')
  if ([string]::IsNullOrWhiteSpace($javaHome)) {
    $javaHome = Join-Path $env:USERPROFILE '.codex\tools\jdk8\jdk8u482-b08'
  }
  $java = Join-Path $javaHome 'bin\javaw.exe'
  if (!(Test-Path -LiteralPath $java)) { throw "Java 8 introuvable: $java" }
  return $javaHome
}

function Ensure-TokenSecret {
  $secret = [Environment]::GetEnvironmentVariable('POP_TOKEN_SECRET', 'User')
  if ([string]::IsNullOrWhiteSpace($secret) -or $secret.Length -lt 32) {
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try {
      $bytes = New-Object byte[] 48
      $rng.GetBytes($bytes)
      $secret = [Convert]::ToBase64String($bytes)
      [Environment]::SetEnvironmentVariable('POP_TOKEN_SECRET', $secret, 'User')
    } finally {
      $rng.Dispose()
    }
  }
  return $secret
}

function Set-EnvFromUserIfDefined([string[]]$Names) {
  foreach ($name in $Names) {
    $value = [Environment]::GetEnvironmentVariable($name, 'User')
    if (![string]::IsNullOrWhiteSpace($value)) {
      Set-Item -Path "Env:$name" -Value $value
    }
  }
}

function Ensure-MariaDb {
  if (Test-Listening 3306) { return }
  $mariaBase = Join-Path $env:USERPROFILE '.codex\tools\mariadb-10.11.16-winx64'
  $dataDir = Join-Path $env:USERPROFILE '.codex\tools\mariadb-data-pop-backend-main'
  $server = Join-Path $mariaBase 'bin\mariadbd.exe'
  $config = Join-Path $dataDir 'my.ini'
  if (!(Test-Path -LiteralPath $server) -or !(Test-Path -LiteralPath $config)) {
    throw 'MariaDB local est introuvable.'
  }
  Step 'Demarrage MariaDB local'
  Start-Process -FilePath $server -ArgumentList @("--defaults-file=$config", "--bind-address=127.0.0.1") -WorkingDirectory $mariaBase -WindowStyle Hidden | Out-Null
  Start-Sleep -Seconds 5
  if (!(Test-Listening 3306)) { throw 'MariaDB n a pas ouvert le port 3306.' }
}

function Stop-TargetWarProcess {
  Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'target\\app-server-1\.0\.0\.war' } |
    ForEach-Object { Stop-Pid ([int]$_.ProcessId) }
}

function Build-Backend {
  Stop-TargetWarProcess
  $javaHome = Resolve-JavaHome
  $env:JAVA_HOME = $javaHome
  $env:Path = "$javaHome\bin;$env:Path"
  Step 'Build backend'
  Push-Location $BackendRoot
  try {
    & .\mvnw.cmd -q -DskipTests package
    if ($LASTEXITCODE -ne 0) { throw 'Build backend echoue.' }
  } finally {
    Pop-Location
  }
  if (!(Test-Path -LiteralPath $WarSource)) { throw "WAR introuvable: $WarSource" }
}

function Copy-BackendArtifact($EnvConfig) {
  $targetDir = Join-Path $RuntimeRoot "$($EnvConfig.Key)\backend"
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
  $targetWar = Join-Path $targetDir 'app-server-1.0.0.war'
  Copy-Item -LiteralPath $WarSource -Destination $targetWar -Force
  return $targetWar
}

function Set-BackendEnvironment($EnvConfig) {
  $env:SERVER_PORT = [string]$EnvConfig.BackendPort
  $env:POP_DB_URL = [Environment]::GetEnvironmentVariable('POP_DB_URL', 'User')
  $env:POP_DB_USERNAME = [Environment]::GetEnvironmentVariable('POP_DB_USERNAME', 'User')
  $env:POP_DB_PASSWORD = [Environment]::GetEnvironmentVariable('POP_DB_PASSWORD', 'User')
  $env:POP_TOKEN_SECRET = Ensure-TokenSecret
  $ttl = [Environment]::GetEnvironmentVariable('POP_TOKEN_TTL_SECONDS', 'User')
  $env:POP_TOKEN_TTL_SECONDS = if ([string]::IsNullOrWhiteSpace($ttl)) { '86400' } else { $ttl }
  Set-EnvFromUserIfDefined @(
    'POP_GOOGLE_OAUTH_CLIENT_IDS',
    'POP_APPLE_OAUTH_CLIENT_IDS',
    'POP_FACEBOOK_APP_ID',
    'POP_FACEBOOK_APP_SECRET',
    'POP_INSTAGRAM_APP_ID',
    'POP_INSTAGRAM_APP_SECRET'
  )
}

function Start-Backend($EnvConfig) {
  if (Test-Listening $EnvConfig.BackendPort) { return Get-ListenerPid $EnvConfig.BackendPort }
  Ensure-MariaDb
  $javaHome = Resolve-JavaHome
  $java = Join-Path $javaHome 'bin\javaw.exe'
  $war = Join-Path $RuntimeRoot "$($EnvConfig.Key)\backend\app-server-1.0.0.war"
  if (!(Test-Path -LiteralPath $war)) {
    Build-Backend
    $war = Copy-BackendArtifact $EnvConfig
  }
  Set-BackendEnvironment $EnvConfig
  Step "$($EnvConfig.Label) backend -> $($EnvConfig.BackendPort)"
  Start-Process -FilePath $java -ArgumentList @('-jar', $war) -WorkingDirectory $BackendRoot -WindowStyle Hidden | Out-Null
  Wait-Port $EnvConfig.BackendPort $HealthcheckTimeoutSec
  return Get-ListenerPid $EnvConfig.BackendPort
}

function Start-Frontend($EnvConfig) {
  if (Test-Listening $EnvConfig.FrontendPort) { return Get-ListenerPid $EnvConfig.FrontendPort }
  if (!(Test-Path -LiteralPath $FrontendRoot)) { throw "Front introuvable: $FrontendRoot" }
  $logs = Get-LogRoot $EnvConfig
  New-Item -ItemType Directory -Force -Path $logs | Out-Null
  $env:EXPO_PUBLIC_POP_API_ORIGIN = $EnvConfig.ApiOrigin
  $env:EXPO_PUBLIC_POP_ENV_LABEL = $EnvConfig.Label
  Set-EnvFromUserIfDefined @(
    'EXPO_PUBLIC_POP_SHARE_ORIGIN',
    'EXPO_PUBLIC_GOOGLE_OAUTH_CLIENT_ID',
    'EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID',
    'EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID',
    'EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID',
    'EXPO_PUBLIC_APPLE_OAUTH_CLIENT_ID',
    'EXPO_PUBLIC_APPLE_SERVICE_ID',
    'EXPO_PUBLIC_FACEBOOK_OAUTH_CLIENT_ID',
    'EXPO_PUBLIC_FACEBOOK_APP_ID',
    'EXPO_PUBLIC_INSTAGRAM_OAUTH_CLIENT_ID',
    'EXPO_PUBLIC_INSTAGRAM_APP_ID'
  )
  $envTemp = Join-Path $RuntimeRoot "$($EnvConfig.Key)\temp"
  New-Item -ItemType Directory -Force -Path $envTemp | Out-Null
  $env:TEMP = $envTemp
  $env:TMP = $envTemp
  Step "$($EnvConfig.Label) front -> $($EnvConfig.FrontendPort)"
  Start-Process -FilePath 'npm.cmd' -ArgumentList @('run', 'web', '--', '--clear', '--port', "$($EnvConfig.FrontendPort)", '--host', 'localhost') -WorkingDirectory $FrontendRoot -RedirectStandardOutput (Join-Path $logs 'frontend.out.log') -RedirectStandardError (Join-Path $logs 'frontend.err.log') -WindowStyle Hidden | Out-Null
  Wait-Port $EnvConfig.FrontendPort $HealthcheckTimeoutSec
  return Get-ListenerPid $EnvConfig.FrontendPort
}

function Start-Proxy($EnvConfig) {
  if (Test-Listening $EnvConfig.ProxyPort) { return Get-ListenerPid $EnvConfig.ProxyPort }
  $node = (Get-Command node -ErrorAction Stop).Source
  $logs = Get-LogRoot $EnvConfig
  New-Item -ItemType Directory -Force -Path $logs | Out-Null
  $env:POP_PROXY_PORT = [string]$EnvConfig.ProxyPort
  $env:POP_FRONTEND_PORT = [string]$EnvConfig.FrontendPort
  $env:POP_BACKEND_PORT = [string]$EnvConfig.BackendPort
  Step "$($EnvConfig.Label) proxy -> $($EnvConfig.ProxyPort)"
  $process = Start-Process -FilePath $node -ArgumentList @($ProxyScript) -WorkingDirectory $BackendRoot -RedirectStandardOutput (Join-Path $logs 'proxy.out.log') -RedirectStandardError (Join-Path $logs 'proxy.err.log') -WindowStyle Hidden -PassThru
  Wait-Port $EnvConfig.ProxyPort 15
  return $process.Id
}

function Wait-Port([int]$Port, [int]$TimeoutSec) {
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  do {
    if (Test-Listening $Port) { return }
    Start-Sleep -Milliseconds 500
  } while ((Get-Date) -lt $deadline)
  throw "Port indisponible: $Port"
}

function Stop-Environment($EnvConfig) {
  $state = Read-State $EnvConfig
  if ($state) {
    Stop-Pid (Get-StateInt $state 'backendPid')
    Stop-Pid (Get-StateInt $state 'frontendPid')
    Stop-Pid (Get-StateInt $state 'proxyPid')
  }
  Stop-Port $EnvConfig.ProxyPort
  Stop-Port $EnvConfig.FrontendPort
  Stop-Port $EnvConfig.BackendPort
  Write-State $EnvConfig @{
    active = $false
    backendPid = 0
    frontendPid = 0
    proxyPid = 0
    backendPort = $EnvConfig.BackendPort
    frontendPort = $EnvConfig.FrontendPort
    proxyPort = $EnvConfig.ProxyPort
  }
  Ok "$($EnvConfig.Label) arrete"
}

function Start-Environment($EnvConfig) {
  $backendPid = Start-Backend $EnvConfig
  $frontendPid = Start-Frontend $EnvConfig
  $proxyPid = Start-Proxy $EnvConfig
  Write-State $EnvConfig @{
    active = $true
    backendPid = $backendPid
    frontendPid = $frontendPid
    proxyPid = $proxyPid
    backendPort = $EnvConfig.BackendPort
    frontendPort = $EnvConfig.FrontendPort
    proxyPort = $EnvConfig.ProxyPort
    apiOrigin = $EnvConfig.ApiOrigin
    frontendUrl = $EnvConfig.FrontendUrl
    proxyUrl = $EnvConfig.ProxyUrl
  }
  Ok "$($EnvConfig.Label) disponible: $($EnvConfig.ProxyUrl)"
  if ($Open) { Start-Process $EnvConfig.ProxyUrl | Out-Null }
}

function Full-Environment($EnvConfig) {
  Stop-Environment $EnvConfig
  Build-Backend
  Copy-BackendArtifact $EnvConfig | Out-Null
  if ($Seed) { Seed-Database }
  Start-Environment $EnvConfig
}

function Seed-Database {
  Ensure-MariaDb
  $mysql = Join-Path $env:USERPROFILE '.codex\tools\mariadb-10.11.16-winx64\bin\mysql.exe'
  if (!(Test-Path -LiteralPath $mysql)) { $mysql = (Get-Command mysql -ErrorAction Stop).Source }
  $user = [Environment]::GetEnvironmentVariable('POP_DB_USERNAME', 'User')
  $pwd = [Environment]::GetEnvironmentVariable('POP_DB_PASSWORD', 'User')
  Step 'Seed base locale'
  & $mysql -h 127.0.0.1 -P 3306 -u $user "--password=$pwd" --database poplitic_db --execute "SOURCE SQL/LOCAL_DEV_SEED.sql"
  if ($LASTEXITCODE -ne 0) { throw 'Seed SQL echoue.' }
  & $mysql -h 127.0.0.1 -P 3306 -u $user "--password=$pwd" --database poplitic_db --execute "SOURCE SQL/LOCAL_LIVE_SEED.sql"
  if ($LASTEXITCODE -ne 0) { throw 'Seed SQL echoue.' }
  & $mysql -h 127.0.0.1 -P 3306 -u $user "--password=$pwd" --database poplitic_db --execute "SOURCE SQL/LOCAL_FEATURE_SEED.sql"
  if ($LASTEXITCODE -ne 0) { throw 'Seed SQL echoue.' }
}

function Show-Status($EnvConfig) {
  $backend = Get-ListenerPid $EnvConfig.BackendPort
  $frontend = Get-ListenerPid $EnvConfig.FrontendPort
  $proxy = Get-ListenerPid $EnvConfig.ProxyPort
  $active = $backend -gt 0 -and $frontend -gt 0 -and $proxy -gt 0
  $state = if ($active) { 'UP' } else { 'DOWN' }
  Write-Host ("{0,-4} {1,-4}  backend:{2,-5} pid:{3,-6}  front:{4,-5} pid:{5,-6}  proxy:{6,-5} pid:{7,-6}  {8}" -f $EnvConfig.Key.ToUpperInvariant(), $state, $EnvConfig.BackendPort, $backend, $EnvConfig.FrontendPort, $frontend, $EnvConfig.ProxyPort, $proxy, $EnvConfig.ProxyUrl)
}

function Show-Logs($EnvConfig) {
  $logs = Get-LogRoot $EnvConfig
  Write-Host "$($EnvConfig.Label) logs: $logs"
  foreach ($file in @('frontend.out.log', 'frontend.err.log', 'proxy.out.log', 'proxy.err.log')) {
    $path = Join-Path $logs $file
    if (Test-Path -LiteralPath $path) {
      Write-Host ""
      Write-Host "== $file =="
      Get-Content -LiteralPath $path -Tail 25
    }
  }
}

function Promote-Environment($EnvConfig) {
  if (!$EnvConfig.PromoteTo) {
    Warn "$($EnvConfig.Label) n a pas de cible de promotion."
    return
  }
  $target = Get-EnvConfig $EnvConfig.PromoteTo
  if ($target.Key -eq 'prod') {
    $confirmation = Read-Host 'Tape PROD pour confirmer'
    if ($confirmation -cne 'PROD') { throw 'Promotion annulee.' }
  }
  Full-Environment $target
}

function Invoke-ActionForEnv([string]$Key) {
  $e = Get-EnvConfig $Key
  switch ($Action) {
    'status' { Show-Status $e }
    'start' { Start-Environment $e }
    'stop' { Stop-Environment $e }
    'restart' { Stop-Environment $e; Start-Environment $e }
    'full' { Full-Environment $e }
    'build' { Build-Backend; Copy-BackendArtifact $e | Out-Null; Ok "$($e.Label) artifact pret" }
    'seed' { Seed-Database }
    'logs' { Show-Logs $e }
    'promote' { Promote-Environment $e }
  }
}

function Show-Menu {
  while ($true) {
    Clear-Host
    Write-Host 'POP DEPLOY LOCAL' -ForegroundColor Cyan
    Write-Host 'DEV / UAT / PROD - local uniquement'
    Write-Host ''
    foreach ($key in $EnvOrder) { Show-Status (Get-EnvConfig $key) }
    Write-Host ''
    Write-Host '1  Full DEV'
    Write-Host '2  Restart DEV'
    Write-Host '3  Full UAT'
    Write-Host '4  Restart UAT'
    Write-Host '5  Full PROD'
    Write-Host '6  Restart PROD'
    Write-Host '7  Start all'
    Write-Host '8  Stop all'
    Write-Host '9  Seed DB'
    Write-Host '0  Quitter'
    $choice = Read-Host 'Action'
    switch ($choice) {
      '1' { $script:Action = 'full'; Invoke-ActionForEnv 'dev'; Pause }
      '2' { $script:Action = 'restart'; Invoke-ActionForEnv 'dev'; Pause }
      '3' { $script:Action = 'full'; Invoke-ActionForEnv 'uat'; Pause }
      '4' { $script:Action = 'restart'; Invoke-ActionForEnv 'uat'; Pause }
      '5' { $script:Action = 'full'; Invoke-ActionForEnv 'prod'; Pause }
      '6' { $script:Action = 'restart'; Invoke-ActionForEnv 'prod'; Pause }
      '7' { $script:Action = 'start'; foreach ($key in $EnvOrder) { Invoke-ActionForEnv $key }; Pause }
      '8' { $script:Action = 'stop'; foreach ($key in $EnvOrder) { Invoke-ActionForEnv $key }; Pause }
      '9' { Seed-Database; Pause }
      '0' { return }
    }
  }
}

if ($Action -eq 'menu') {
  Show-Menu
  exit 0
}

$targets = Get-TargetEnvs
foreach ($target in $targets) {
  Invoke-ActionForEnv $target
}
