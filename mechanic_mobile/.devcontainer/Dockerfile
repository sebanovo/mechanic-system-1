FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Instalar Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Marcar el directorio como seguro para Git (Evita errores en DevContainers)
RUN git config --global --add safe.directory /opt/flutter

RUN flutter config --enable-web

WORKDIR /app

# Al estar el contexto en "..", Docker encontrará estos archivos en la raíz
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

EXPOSE 5200

CMD ["sleep", "infinity"]