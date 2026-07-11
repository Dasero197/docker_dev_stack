FROM node:22-alpine AS build
WORKDIR /app
RUN apk add --no-cache git
RUN git clone --depth 1 --branch v1.0.4 https://github.com/lovasoa/jsonjoy-builder.git .
RUN npm install
RUN npm ci
RUN npm run build:demo
# Retire le script tiers externe (cdn.gpteng.co) pour un usage 100% local/offline
RUN sed -i '/cdn.gpteng.co/d' dist-demo/index.html

FROM nginx:alpine
COPY --from=build /app/dist-demo /usr/share/nginx/html
EXPOSE 80