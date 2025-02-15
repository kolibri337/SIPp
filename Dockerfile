FROM ubuntu:22.04

USER root

# Установим зависимости и SIPp
RUN apt-get update && \
    apt-get install -y \
    wget \
    build-essential \
    libncurses5-dev \
    libssl-dev \
    libpcap-dev \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем и устанавливаем SIPp
RUN wget https://github.com/SIPp/sipp/releases/download/v3.7.3/sipp-3.7.3.tar.gz && \
    tar -xvzf sipp-3.7.3.tar.gz && \
    cd sipp-3.7.0 && \
    cmake . -DUSE_GSL=1 -DUSE_PCAP=1 \
    make && \
    make install

# Создаем непривилегированного пользователя
RUN useradd -m sippuser

# Копируем сценарий и скрипт
COPY basic_call.xml /app/basic_call.xml
COPY run_calls.sh /app/run_calls.sh

# Устанавливаем владельца файлов
RUN chown -R sippuser:sippuser /app

# Делаем скрипт исполняемым
RUN chmod +x /app/run_calls.sh

# Устанавливаем рабочую директорию
WORKDIR /app

# Переключаемся на непривилегированного пользователя
USER sippuser

# Укажем ENTRYPOINT
CMD ["./run_calls.sh"]
