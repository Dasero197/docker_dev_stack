# 🐳 Dev Stack — Guide rapide

Une stack Docker complète et modulaire, prête pour le développement, la data science, et l'automatisation, avec vos domaines `.local`.

## 🚀 Démarrage rapide

### 1. Préparation et Configuration
Lancez le script de configuration initiale. Il va générer votre fichier de configuration sécurisé (`.env`) et ajouter les domaines locaux.
```bash
sudo bash setup-hosts.sh
```

> **Important :** Éditez le fichier `.env` nouvellement créé pour configurer vos mots de passe (`GLOBAL_PASSWORD`, `GLOBAL_USER`, etc.). Vous pouvez aussi décommenter des variables pour surcharger des configurations spécifiques.

### 2. Lancer la Stack (Modularité)
La stack utilise des **profils Docker Compose** pour économiser les ressources de votre machine. Vous ne lancez que ce dont vous avez besoin.

**Option A : Lancer toute la stack d'un coup**
```bash
# Lance Traefik et tous les profils configurés dans votre .env
# (Par défaut, si COMPOSE_PROFILES n'est pas défini, lance tous les services non profilés)
# Pour tout forcer :
docker compose --profile db --profile db_tools --profile devtools --profile messaging --profile storage --profile automation --profile data up -d
```

**Option B : Lancer par catégorie (Recommandé)**
```bash
# Exemple : Lancer uniquement les bases de données et les outils d'admin
docker compose --profile db --profile db_tools up -d

# Exemple : Lancer uniquement l'environnement Data Science
docker compose --profile data up -d
```

**Option C : Configuration persistante via `.env`**
Dans votre fichier `.env`, vous pouvez définir :
```env
COMPOSE_PROFILES=db,devtools,db_tools
```
Ensuite, un simple `docker compose up -d` lancera automatiquement ces profils.

---

## 🗺️ Accès par domaine local

> **Note :** Les identifiants ci-dessous sont ceux **par défaut**. Si vous avez modifié votre `.env`, utilisez vos propres valeurs.

| Service | URL | Profil Docker | Identifiants par défaut |
|---|---|---|---|
| **Traefik** (proxy) | http://traefik.local | *(Core)* | — |
| **Portainer** | http://portainer.local | `devtools` | *Créer au 1er lancement* |
| **phpMyAdmin** | http://phpmyadmin.local | `db_tools` | root / `GLOBAL_PASSWORD` |
| **pgAdmin** | http://pgadmin.local | `db_tools` | dev@local.dev / `GLOBAL_PASSWORD` |
| **Mongo Express** | http://mongo.local | `db_tools` | admin / `GLOBAL_PASSWORD` |
| **Adminer** | http://adminer.local | `db_tools` | → *choisir la DB* |
| **RedisInsight** | http://redis.local | `db` | — *(auth Redis requise)* |
| **Mailpit** | http://mail.local | `messaging` | — |
| **RabbitMQ** | http://rabbitmq.local | `messaging` | `GLOBAL_USER` / `GLOBAL_PASSWORD` |
| **MinIO console** | http://minio.local | `storage` | `GLOBAL_USER` / `GLOBAL_PASSWORD` |
| **n8n** | http://n8n.local | `automation`| admin / `GLOBAL_PASSWORD` |
| **JupyterLab** | http://jupyter.local | `data` | token : `GLOBAL_PASSWORD` |

---

## 🔌 Connexions depuis vos apps (host → container)

| Service | Host | Port | User par défaut | Password par défaut |
|---|---|---|---|---|
| MySQL | `localhost` | 3306 | `GLOBAL_USER` | `GLOBAL_PASSWORD` |
| PostgreSQL | `localhost` | 5432 | `GLOBAL_USER` | `GLOBAL_PASSWORD` |
| MongoDB | `localhost` | 27017 | `GLOBAL_USER` | `GLOBAL_PASSWORD` |
| Redis | `localhost` | 6379 | — | `GLOBAL_PASSWORD` |
| SMTP (Mailpit) | `localhost` | 1025 | — | — |
| RabbitMQ AMQP | `localhost` | 5672 | `GLOBAL_USER` | `GLOBAL_PASSWORD` |
| MinIO S3 API | `localhost` | 9000 | `GLOBAL_USER` | `GLOBAL_PASSWORD` |
| Soketi WS | `localhost` | 6001 | — | — |

> **Depuis un container vers un autre**, utilisez le nom du service comme host :
> ex. `mysql`, `postgres`, `redis`, `mongo`, `rabbitmq`

---

## 🛑 Commandes utiles

```bash
# Arrêter tout (sans supprimer les données)
docker compose stop

# Relancer un service spécifique
docker compose restart mysql

# Voir les logs d'un service
docker compose logs -f n8n

# Tout supprimer (⚠️ données incluses)
docker compose down -v

# Mettre à jour toutes les images (pour le profil actif)
docker compose pull && docker compose up -d
```

---

## 🔒 Utilisation d'images Docker privées

Si vous souhaitez ajouter vos propres applications hébergées sur un registre privé (Docker Hub, GitHub Container Registry, GitLab, etc.), Docker Compose utilisera automatiquement l'authentification de votre machine hôte.

1. **Connectez-vous** depuis votre terminal (une seule fois par machine) :
   ```bash
   docker login
   # ou pour un registre spécifique :
   docker login registry.gitlab.com
   ```
2. **Ajoutez votre service** dans le `docker-compose.yml` avec l'URL complète :
   ```yaml
     mon-api:
       image: registry.gitlab.com/mon-groupe/mon-api:latest
       profiles: ["apps"] # Créez un nouveau profil si besoin
   ```
> ⚠️ **Ne mettez jamais vos identifiants de registre en clair** dans le `docker-compose.yml` ou le `.env`. Le `docker login` est la méthode sécurisée et recommandée.

---

## 📁 Structure recommandée

```
devstack/
├── docker-compose.yml
├── setup-hosts.sh
├── .env                    ← Ne le commitez jamais ! Géré par le script setup.
├── .env.example            ← Modèle avec les variables commentées.
```
