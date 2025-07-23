# Используем стабильный образ n8n (Alpine Linux)
FROM docker.n8n.io/n8nio/n8n:1.102.4

# Переключаемся на root для установки пакетов
USER root

# Обновляем пакеты и устанавливаем необходимые зависимости
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
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

# Возвращаемся к пользователю node
USER node

# Переменные окружения для n8n
ENV N8N_USER_FOLDER=/data \
    DB_TYPE=sqlite \
    DB_SQLITE_DATABASE=/data/database.sqlite \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    PATH="/opt/venv/bin:$PATH"

# Expose порт
EXPOSE 5678

# Запускаем n8n
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]