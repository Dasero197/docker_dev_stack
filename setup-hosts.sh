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

if [ -f ".env" ]; then
  # Sourcing .env pour que Python lise COMPOSE_PROFILES et DOMAIN_SUFFIX
  set -a
  source .env
  set +a
fi

echo "🔍  Analyse du docker-compose.yml pour extraire les domaines dynamiquement..."

if command -v python3 &> /dev/null; then
  DOMAINS_STR=$(docker compose config --format json 2>/dev/null | python3 -c '
import sys, json, os, re
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

active_profiles_str = os.getenv("COMPOSE_PROFILES", "")
active_profiles = [p.strip() for p in active_profiles_str.split(",") if p.strip()]
active_domains = set()
all_domains = set()

for s_name, service in data.get("services", {}).items():
    s_profiles = service.get("profiles", [])
    is_active = not active_profiles or not s_profiles or any(p in active_profiles for p in s_profiles)
    for k, v in service.get("labels", {}).items():
        if k.startswith("traefik.http.routers.") and k.endswith(".rule"):
            match = re.search(r"Host\(`([^`]+)`\)", v)
            if match:
                domain = match.group(1)
                all_domains.add(domain)
                if is_active:
                    active_domains.add(domain)

ignored_domains = all_domains - active_domains

for d in sorted(list(active_domains)):
    print(f"ACTIVE:{d}")
for d in sorted(list(ignored_domains)):
    print(f"IGNORED:{d}")
')
else
  echo "⚠️  ATTENTION : Python 3 n'\''est pas installé sur votre système."
  echo "👉 L'\''absence de Python empêche le script de filtrer intelligemment les domaines selon vos profils actifs."
  echo "👉 Tous les domaines seront ajoutés par défaut à votre fichier hosts."
  echo "💡 Conseil : Installez Python 3 et relancez ce script pour garder votre fichier hosts propre et léger !"
  echo ""
  DOMAINS_RAW=$(grep -oE "Host\(\`[^\`]+\`\)" docker-compose.yml | cut -d"\`" -f2 | sort -u)
  DOMAINS_STR=$(for d in $DOMAINS_RAW; do echo "ACTIVE:$d"; done)
fi

if [ -z "$DOMAINS_STR" ]; then
  echo "❌  Erreur: Impossible de lire les domaines depuis docker-compose. Assurez-vous que docker-compose fonctionne."
  exit 1
fi

ACTIVE_DOMAINS=()
IGNORED_DOMAINS=()
while IFS= read -r line; do
  if [[ "$line" == ACTIVE:* ]]; then
    ACTIVE_DOMAINS+=("${line#ACTIVE:}")
  elif [[ "$line" == IGNORED:* ]]; then
    IGNORED_DOMAINS+=("${line#IGNORED:}")
  fi
done <<< "$DOMAINS_STR"

if [ "$EUID" -ne 0 ]; then
  echo "❌  Lance ce script avec sudo : sudo bash setup-hosts.sh"
  exit 1
fi

OLD_DOMAINS=()
if grep -q "$MARKER" /etc/hosts; then
  # Extraire les anciens domaines avant de les supprimer
  OLD_DOMAINS_STR=$(sed -n "/^${MARKER}$/,/^${MARKER} END$/p" /etc/hosts | grep -E "^127\.0\.0\.1" | awk '{print $2}')
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      OLD_DOMAINS+=("$line")
    fi
  done <<< "$OLD_DOMAINS_STR"

  echo "🔄  Nettoyage des anciennes entrées devstack…"
  # macOS et Linux compatibles, suppression par bloc exact
  if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "/^${MARKER}$/,/^${MARKER} END$/d" /etc/hosts
  else
    sed -i "/^${MARKER}$/,/^${MARKER} END$/d" /etc/hosts
  fi
fi

REMOVED_DOMAINS=()
for old in "${OLD_DOMAINS[@]}"; do
  found=0
  for active in "${ACTIVE_DOMAINS[@]}"; do
    if [ "$old" = "$active" ]; then
      found=1
      break
    fi
  done
  if [ $found -eq 0 ]; then
    REMOVED_DOMAINS+=("$old")
  fi
done

# Ajoute les nouvelles entrées
echo "" >> /etc/hosts
echo "$MARKER" >> /etc/hosts
for domain in "${ACTIVE_DOMAINS[@]}"; do
  echo "127.0.0.1  $domain" >> /etc/hosts
done
echo "$MARKER END" >> /etc/hosts

echo "✅  Domaines actifs configurés dans /etc/hosts :"
for domain in "${ACTIVE_DOMAINS[@]}"; do
  echo "   🟢 http://$domain"
done

if [ ${#IGNORED_DOMAINS[@]} -gt 0 ]; then
  echo ""
  echo "⏸️   Domaines inactifs (ignorés car profils non activés) :"
  for domain in "${IGNORED_DOMAINS[@]}"; do
    echo "   ⚪ http://$domain"
  done
fi

if [ ${#REMOVED_DOMAINS[@]} -gt 0 ]; then
  echo ""
  echo "🗑️   Domaines supprimés de /etc/hosts (n'étaient plus actifs) :"
  for domain in "${REMOVED_DOMAINS[@]}"; do
    echo "   🔴 http://$domain"
  done
fi

echo ""
echo "🚀  Lance maintenant : docker compose up -d"
