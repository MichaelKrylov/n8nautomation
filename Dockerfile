FROM docker.n8n.io/n8nio/n8n:1.102.4

# Установка ffmpeg (с явным указанием пакетов)
USER root
RUN apk update && \
    apk add --no-cache \
        ffmpeg \
        tini  # Важно для корректного завершения процессов

RUN mkdir -p /data && chown -R node:node /data

USER node

# Настройки n8n
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite

# Запуск через tini для обработки сигналов
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]