# ШАГ 1: Используем образ n8n на базе DEBIAN. Это ключевое изменение.
FROM docker.n8n.io/n8nio/n8n:1.102.4-debian

# Переключаемся на root для установки
USER root

# ШАГ 2: Используем apt-get, который теперь будет работать
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    ffmpeg tini gcc g++

# Создаем виртуальное окружение
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Устанавливаем Spleeter. На Debian это должно пройти гладко.
RUN pip install --upgrade pip && \
    pip install spleeter

# Устанавливаем права для пользователя node
RUN chown -R node:node /opt/venv

# Возвращаемся к пользователю node
USER node

# Настройки n8n (остаются без изменений)
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]