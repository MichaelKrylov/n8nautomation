# Этап 1: Сборка Python окружения
FROM python:3.11-slim as python-builder

# Устанавливаем системные зависимости для компиляции
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libblas-dev \
    liblapack-dev \
    gfortran \
    ffmpeg \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Создаем виртуальное окружение
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Обновляем pip и устанавливаем базовые пакеты
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Устанавливаем TensorFlow (используем более совместимую версию)
RUN pip install --no-cache-dir tensorflow==2.13.0

# Устанавливаем Spleeter
RUN pip install --no-cache-dir spleeter

# Предварительно загружаем основные модели Spleeter
RUN mkdir -p /tmp/spleeter_models && \
    python -c "from spleeter.separator import Separator; Separator('spleeter:2stems-16kHz')" || \
    echo "Модели будут загружены при первом использовании"

# Этап 2: Финальный образ на основе официального n8n
FROM docker.n8n.io/n8nio/n8n:1.102.4

USER root

# Устанавливаем минимально необходимые системные пакеты
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    tini \
    && rm -rf /var/cache/apk/*

# Копируем готовое Python окружение из первого этапа
COPY --from=python-builder /opt/venv /opt/venv
COPY --from=python-builder /usr/bin/ffmpeg /usr/bin/ffmpeg

# Настраиваем PATH для доступа к Python пакетам
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH="/opt/venv/lib/python3.11/site-packages"

# Устанавливаем права доступа для пользователя node
RUN chown -R node:node /opt/venv

# Переключаемся обратно на пользователя node (требование n8n)
USER node

# Создаем директорию для данных (совместима с Amvera)
RUN mkdir -p /data

# Переменные окружения для n8n (оптимизированы для Amvera)
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_DIAGNOSTICS_ENABLED=false
ENV N8N_VERSION_NOTIFICATIONS_ENABLED=false
ENV N8N_TEMPLATES_ENABLED=false
ENV N8N_ONBOARDING_FLOW_DISABLED=true

# Переменные для оптимизации Python и TensorFlow
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV TF_CPP_MIN_LOG_LEVEL=2

# Запуск через tini для корректной обработки сигналов
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]