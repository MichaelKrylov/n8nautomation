# Gunakan gambar n8n resmi
FROM docker.n8n.io/n8nio/n8n:1.102.4

# Beralih ke pengguna root untuk menginstal paket
USER root

# Instal dependensi sistem menggunakan apk
# build-base adalah padanan Alpine untuk build-essential (mencakup gcc, g++, dll.)
RUN apk update && apk add --no-cache \
    ffmpeg \
    tini \
    python3 \
    py3-pip \
    build-base \
    python3-dev \
    libffi-dev \
    openblas-dev \
    lapack-dev \
    gfortran

# Buat lingkungan virtual menggunakan Python3 sistem
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Tingkatkan pip dan instal Spleeter
# Kami menghapus pin versi TensorFlow yang ketat, membiarkan pip memilih yang kompatibel
RUN pip install --upgrade pip && \
    pip install spleeter

# Kembalikan kepemilikan kepada pengguna node, yang menjalankan n8n
RUN chown -R node:node /opt/venv

# Beralih kembali ke pengguna node
USER node

# Simpan sisa pengaturan n8n Anda tidak berubah
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
ENV N8N_USER_FOLDER=/data
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
# Pastikan PATH untuk venv juga tersedia untuk pengguna node
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]