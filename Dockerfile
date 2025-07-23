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

# Создаем симлинк для python (если нужно)
RUN ln -sf python3 /usr/bin/python

# Обновляем pip и устанавливаем Spleeter
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install tensorflow==2.12.0 && \
    pip3 install spleeter

# Предварительно скачиваем модели Spleeter (опционально, но ускорит первый запуск)
RUN python3 -c "import spleeter; from spleeter.separator import Separator; Separator('spleeter:2stems-16kHz')"

# Возвращаемся к пользователю node
USER node

# Настройки n8n
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite

# Запуск через tini для обработки сигналов
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]