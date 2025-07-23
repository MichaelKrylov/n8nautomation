FROM docker.n8n.io/n8nio/n8n:1.102.4

# Установка системных зависимостей
USER root

# Сначала удаляем существующие Python 3.12 пакеты
RUN apk del python3 python3-dev py3-pip py3-setuptools

# Устанавливаем Python 3.9 из основного репозитория Alpine 3.22
RUN apk add --no-cache \
        python3=3.9.18-r0 \
        python3-dev=3.9.18-r0 \
        py3-pip \
        && \
    ln -sf python3 /usr/bin/python

# Устанавливаем остальные зависимости
RUN apk add --no-cache \
        ffmpeg \
        tini \
        gcc \
        g++ \
        musl-dev \
        libffi-dev \
        openblas-dev \
        lapack-dev \
        gfortran

# Создаем виртуальное окружение
RUN python3 -m venv /opt/venv

# Устанавливаем Python-пакеты
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip setuptools wheel && \
    pip install tensorflow==2.10.0 spleeter  # Версия TensorFlow для Python 3.9

# Предварительная загрузка моделей Spleeter
RUN python3 -c "import spleeter; from spleeter.separator import Separator; Separator('spleeter:2stems-16kHz')" || echo "Model download failed"

# Настраиваем права
RUN chown -R node:node /opt/venv

# Возвращаемся к пользователю node
USER node

# Настройки n8n
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false \
    N8N_USER_FOLDER=/data \
    DB_TYPE=sqlite \
    DB_SQLITE_DATABASE=/data/database.sqlite \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]