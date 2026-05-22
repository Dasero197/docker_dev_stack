#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  setup-hosts.sh — Ajoute les domaines *.local dans /etc/hosts
#  Usage : sudo bash setup-hosts.sh
# ═══════════════════════════════════════════════════════════════

set -e

# Génération du fichier .env s'il n'existe pas
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  echo "🆕 Création du fichier .env à partir de .env.example..."
  if [ -n "$SUDO_USER" ]; then
    sudo -u "$SUDO_USER" cp .env.example .env
  else
    cp .env.example .env
  fi
  echo "⚠️  N'oublie pas de vérifier et modifier les mots de passe dans .env si nécessaire !"
  echo ""
fi

MARKER="# ── devstack local domains ──"

# Génération du fichier openapi dummy s'il n'existe pas
if [ ! -f "openapi/openapi.json" ]; then
  echo "🆕 Création d'un fichier openapi.json dummy..."
  mkdir -p openapi
  cat << 'EOF' > openapi/openapi.json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Dummy API",
    "version": "1.0.0"
  },
  "paths": {
    "/ping": {
      "get": {
        "summary": "Ping endpoint",
        "responses": {
          "200": {
            "description": "OK",
            "content": {
              "application/json": {
                "schema": {
                  "type": "string",
                  "example": "pong"
                }
              }
            }
          }
        }
      }
    }
  }
}
EOF
  # Ajuster les permissions si exécuté avec sudo
  if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER" openapi
  fi
fi

DOMAINS=(
  "traefik.local"
  "phpmyadmin.local"
  "pgadmin.local"
  "mongo.local"
  "redis.local"
  "adminer.local"
  "mail.local"
  "rabbitmq.local"
  "soketi.local"
  "minio.local"
  "portainer.local"
  "n8n.local"
  "jupyter.local"
  "api-tester.local"
  "swagger.local"
  "mock-api.local"
  "search.local"
  "logs.local"
  "sonar.local"
)

if [ "$EUID" -ne 0 ]; then
  echo "❌  Lance ce script avec sudo : sudo bash setup-hosts.sh"
  exit 1
fi

# Supprime les anciennes entrées si elles existent
if grep -q "$MARKER" /etc/hosts; then
  echo "🔄  Suppression des anciennes entrées devstack…"
  # macOS et Linux compatibles
  START_LINE=$(grep -n "$MARKER" /etc/hosts | head -1 | cut -d: -f1)
  END_LINE=$((START_LINE + ${#DOMAINS[@]} + 1))
  if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "${START_LINE},${END_LINE}d" /etc/hosts
  else
    sed -i "${START_LINE},${END_LINE}d" /etc/hosts
  fi
fi

# Ajoute les nouvelles entrées
echo "" >> /etc/hosts
echo "$MARKER" >> /etc/hosts
for domain in "${DOMAINS[@]}"; do
  echo "127.0.0.1  $domain" >> /etc/hosts
done
echo "$MARKER END" >> /etc/hosts

echo ""
echo "✅  Domaines ajoutés dans /etc/hosts :"
for domain in "${DOMAINS[@]}"; do
  echo "   → http://$domain"
done
echo ""
echo "🚀  Lance maintenant : docker compose up -d"
