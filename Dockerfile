FROM docker.n8n.io/n8nio/n8n:1.102.4

USER root

# Устанавливаем системные зависимости
RUN apk update && \
    apk add --no-cache \
        ffmpeg \
        tini \
        python3 \
        py3-pip \
        python3-dev \
        gcc \
        g++ \
        musl-dev \
        libffi-dev \
        openblas-dev \
        lapack-dev \
        gfortran

# Создаем виртуальное окружение
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Устанавливаем Python-пакеты
RUN pip install --upgrade pip setuptools wheel && \
    pip install tensorflow==2.16.2 spleeter

# Предварительная загрузка моделей Spleeter
RUN python3 -c "import spleeter; from spleeter.separator import Separator; Separator('spleeter:2stems-16kHz')" || echo "Model download failed"

# Права на папку
RUN chown -R node:node /opt/venv

USER node

# Настройки n8n
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]