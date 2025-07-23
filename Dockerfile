FROM docker.n8n.io/n8nio/n8n:1.102.4

USER root

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    python3.11 python3.11-dev python3-pip \
    ffmpeg tini gcc g++ libffi-dev libopenblas-dev liblapack-dev gfortran

# Создаем виртуальное окружение
RUN python3.11 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Устанавливаем Python-пакеты
RUN pip install --upgrade pip setuptools wheel && \
    pip install tensorflow==2.16.2 spleeter

# Права
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