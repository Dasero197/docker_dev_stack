FROM diegosouzapw/omniroute:latest

USER root

# Installation directe de Chromium et des dépendances nécessaires via APT
RUN apt-get update && apt-get install -y \
    curl \
    chromium \
    ca-certificates \
    fonts-liberation \
    libnss3 \
    xdg-utils \
    && rm -rf /var/lib/apt-lists/* \
    && ln -sf /usr/bin/chromium /usr/bin/google-chrome \
    && ln -sf /usr/bin/chromium /usr/bin/chrome

RUN mkdir -p /app/node_modules/tls-client/bin /tmp/tls-client \
    && curl -L "https://github.com/BogdanFin/tls-client/releases/download/v1.16.0/tls-client-linux-ubuntu-amd64-v1.16.0.so" \
    -o /app/node_modules/tls-client/bin/tls-client-linux-ubuntu-amd64-1.16.0.so \
    && cp /app/node_modules/tls-client/bin/tls-client-linux-ubuntu-amd64-1.16.0.so /tmp/tls-client/

# Définition des variables d'environnement globales pour indiquer l'exécutable
ENV CHROME_PATH=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium

USER node