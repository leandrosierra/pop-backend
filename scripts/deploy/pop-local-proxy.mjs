import http from "node:http";
import net from "node:net";

const proxyPort = Number(process.env.POP_PROXY_PORT || 8090);
const frontendPort = Number(process.env.POP_FRONTEND_PORT || 8082);
const backendPort = Number(process.env.POP_BACKEND_PORT || 8080);

const apiPrefixes = ["/user", "/question", "/stat", "/discussion", "/budget", "/actualite", "/loi"];
const noStoreHeaders = {
  "cache-control": "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0",
  pragma: "no-cache",
  expires: "0",
  "surrogate-control": "no-store"
};

const isApiRequest = (url = "") => apiPrefixes.some((prefix) => url === prefix || url.startsWith(`${prefix}/`));

const targetFor = (url = "") => {
  if (isApiRequest(url)) {
    return { port: backendPort, host: "127.0.0.1" };
  }
  return { port: frontendPort, host: "localhost" };
};

const proxyHttp = (clientRequest, clientResponse) => {
  const target = targetFor(clientRequest.url);
  const apiRequest = isApiRequest(clientRequest.url);
  const headers = {
    ...clientRequest.headers,
    host: `${target.host}:${target.port}`,
    "x-forwarded-host": clientRequest.headers.host || "",
    "x-forwarded-proto": "http"
  };
  delete headers["if-none-match"];
  delete headers["if-modified-since"];
  if (apiRequest && headers.origin) {
    headers.origin = `http://localhost:${proxyPort}`;
  }

  const upstream = http.request(
    {
      host: target.host,
      port: target.port,
      method: clientRequest.method,
      path: clientRequest.url,
      headers
    },
    (upstreamResponse) => {
      const responseHeaders = {
        ...upstreamResponse.headers,
        ...noStoreHeaders
      };
      delete responseHeaders.etag;
      clientResponse.writeHead(upstreamResponse.statusCode || 502, responseHeaders);
      upstreamResponse.on("error", () => clientResponse.destroy());
      upstreamResponse.pipe(clientResponse);
    }
  );

  upstream.on("error", () => {
    if (clientResponse.headersSent) return clientResponse.end();
    clientResponse.writeHead(502, { "content-type": "text/plain; charset=utf-8" });
    clientResponse.end("POP local service unavailable");
  });

  clientRequest.on("error", () => upstream.destroy());
  clientResponse.on("error", () => upstream.destroy());
  clientRequest.pipe(upstream);
};

const proxyUpgrade = (request, socket, head) => {
  const target = targetFor(request.url);
  const upstream = net.connect(target.port, target.host, () => {
    upstream.write(
      `${request.method} ${request.url} HTTP/${request.httpVersion}\r\n` +
        Object.entries({
          ...request.headers,
          host: `${target.host}:${target.port}`
        })
          .map(([key, value]) => `${key}: ${value}`)
          .join("\r\n") +
        "\r\n\r\n"
    );
    if (head.length) upstream.write(head);
    socket.pipe(upstream).pipe(socket);
  });

  upstream.on("error", () => socket.destroy());
  socket.on("error", () => upstream.destroy());
  socket.on("close", () => upstream.destroy());
};

const server = http.createServer(proxyHttp);
server.on("upgrade", proxyUpgrade);
server.listen(proxyPort, "127.0.0.1", () => {
  process.stdout.write(`POP local proxy listening on http://127.0.0.1:${proxyPort}\n`);
});
