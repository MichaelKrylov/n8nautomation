# Используем стабильный образ n8n (Alpine Linux)
FROM docker.n8n.io/n8nio/n8n:latest

# Переключаемся на root для установки пакетов
USER root

# Обновляем пакеты и устанавливаем необходимые зависимости для Alpine
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
    openssl-dev

# Создаем виртуальное окружение Python (для Alpine нужно установить py3-venv)
RUN apk add --no-cache py3-virtualenv && \
    python3 -m venv /opt/venv

# Активируем виртуальное окружение
ENV PATH="/opt/venv/bin:$PATH"

# Обновляем pip и устанавливаем базовые пакеты
RUN pip install --upgrade pip setuptools wheel

# Устанавливаем numpy отдельно с фиксированной версией для избежания конфликтов
RUN pip install numpy==1.24.3

# Устанавливаем spleeter
RUN pip install spleeter

# Даем права на виртуальное окружение пользователю node
RUN chown -R node:node /opt/venv

# Возвращаемся к пользователю node
USER node

# Переменные окружения для n8n
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV PATH="/opt/venv/bin:$PATH"

# Expose порт
EXPOSE 5678

# Запускаем n8n
CMD ["n8n", "start"]