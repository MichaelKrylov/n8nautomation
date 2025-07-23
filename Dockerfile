FROM docker.n8n.io/n8nio/n8n:1.102.4

# Установка системных зависимостей
USER root

# Обновляем пакеты и устанавливаем необходимые зависимости
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

# Создаем симлинк для python
RUN ln -sf python3 /usr/bin/python

# Создаем виртуальное окружение в системной директории
RUN python3 -m venv /opt/venv

# Активируем виртуальное окружение и устанавливаем пакеты
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip setuptools wheel && \
    pip install tensorflow==2.12.0 && \
    pip install spleeter

# Предварительно скачиваем модели Spleeter для ускорения первого запуска
RUN python3 -c "import spleeter; from spleeter.separator import Separator; Separator('spleeter:2stems-16kHz')" || echo "Model download failed, will download on first use"

# Даем доступ к виртуальному окружению для node пользователя
RUN chown -R node:node /opt/venv

# Возвращаемся к пользователю node
USER node

# Настройки n8n для продакшена
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

# Убеждаемся, что виртуальное окружение доступно
ENV PATH="/opt/venv/bin:$PATH"

# Запуск через tini для корректной обработки сигналов
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]
