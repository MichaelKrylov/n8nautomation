# Используем официальный образ n8n
FROM docker.n8n.io/n8nio/n8n:1.102.4

# Переключаемся на пользователя root для установки пакетов
USER root

# Устанавливаем системные зависимости через apk
# build-base - это аналог build-essential, включает gcc, g++, make и т.д.
# python3-dev - заголовочные файлы для сборки Python-пакетов
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    tini \
    build-base \
    python3-dev \
    libffi-dev \
    openblas-dev \
    lapack-dev \
    gfortran

# Создаем виртуальное окружение, используя системный Python3
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Обновляем pip и устанавливаем Spleeter
# Убираем жесткую привязку к версии TensorFlow, позволяя pip выбрать совместимую
RUN pip install --upgrade pip && \
    pip install spleeter

# Возвращаем права пользователю node, от которого работает n8n
RUN chown -R node:node /opt/venv

# Переключаемся обратно на пользователя node
USER node

# Оставляем остальные настройки n8n без изменений
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
# Убедимся, что PATH для venv доступен и для пользователя node
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]