FROM node:22-alpine
WORKDIR /app
RUN apk add --no-cache postgresql-client
COPY package*.json ./
RUN npm ci --omit=dev
COPY node ./node
COPY SQL/DB_CREATION.sql /docker-init/DB_CREATION.sql
COPY SQL/Init_script_pg.sql /docker-init/Init_script_pg.sql
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sed -i 's/\r$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENV SERVER_PORT=8080
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=192"
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 CMD wget -q --spider http://127.0.0.1:8080/health || exit 1
ENTRYPOINT ["/docker-entrypoint.sh"]
