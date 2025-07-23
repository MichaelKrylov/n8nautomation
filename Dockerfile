# Используем стабильный образ n8n (Alpine Linux)
FROM docker.n8n.io/n8nio/n8n:1.102.4

USER root

# Устанавливаем Python 3.10 и необходимые зависимости
RUN apk update && apk add --no-cache \
    python3.10 \
    py3-pip \
    python3.10-dev \
    build-base \
    linux-headers \
    ffmpeg \
    git \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    openblas-dev \
    lapack-dev \
    gfortran

# Ссылка python3 -> python3.10
RUN ln -sf python3.10 /usr/bin/python3

# Создаем виртуальное окружение Python
RUN python3 -m venv /opt/venv

# Активируем виртуальное окружение
ENV PATH="/opt/venv/bin:$PATH"

# Обновляем pip и устанавливаем базовые пакеты
RUN pip install --upgrade pip setuptools wheel

# Устанавливаем совместимые версии пакетов
RUN pip install --no-cache-dir \
    numpy==1.26.0 \
    tensorflow==2.15.0 \
    spleeter==2.4.0

# Даем права на виртуальное окружение пользователю node
RUN chown -R node:node /opt/venv

USER node

ENV N8N_USER_FOLDER=/data \
    DB_TYPE=sqlite \
    DB_SQLITE_DATABASE=/data/database.sqlite \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    PATH="/opt/venv/bin:$PATH"

EXPOSE 5678

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]