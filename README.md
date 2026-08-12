# 🐳 Dev Stack — L'Environnement de Développement Ultime

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/Dasero197/docker_dev_stack?style=for-the-badge&color=ffd700&logo=github)
![GitHub forks](https://img.shields.io/github/forks/Dasero197/docker_dev_stack?style=for-the-badge&color=orange&logo=github)
![GitHub issues](https://img.shields.io/github/issues/Dasero197/docker_dev_stack?style=for-the-badge&color=red&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/Dasero197/docker_dev_stack?style=for-the-badge&color=success&logo=github)
![Visiteurs](https://komarev.com/ghpvc/?username=Dasero197-docker-dev-stack&label=VISITEURS&color=blue&style=for-the-badge)

</div>

Bienvenue sur **Dev Stack** ! Ce dépôt met à disposition un environnement Docker local complet, modulaire et "plug-and-play" pour les développeurs, conçu pour centraliser tous les outils dont vous avez besoin sans polluer votre machine hôte.

Que vous fassiez du **Python**, du **Node.js**, du **Dart/Flutter** ou de la **Data Science**, cette stack s'adapte à vos besoins grâce à un système de **profils**. Vous ne lancez que ce dont vous avez besoin !

---

## 🚀 Démarrage rapide

### 1. Préparation et Configuration
Lancez le script de configuration initiale. Il va générer votre fichier de configuration sécurisé (`.env`) et ajouter les domaines locaux à votre fichier `hosts` pour un accès facile sans numéro de port.
```bash
sudo bash setup-hosts.sh
```

> **Important :** Éditez le fichier `.env` nouvellement créé pour configurer vos mots de passe (`GLOBAL_PASSWORD`, `GLOBAL_USER`, etc.). Les variables commentées héritent automatiquement des valeurs par défaut.

> 💡 **Astuce (Mots de passe avec caractères spéciaux) :** Évitez absolument d'utiliser les caractères `@`, `%`, `:`, et `/` dans vos mots de passe (`GLOBAL_PASSWORD`). 
> Certains outils (comme Python Alembic utilisé par Flowsint) plantent s'ils voient un `%` dans l'URL de la base de données, rendant l'encodage URL impossible. Privilégiez des mots de passe longs avec des lettres, chiffres, et des caractères sûrs comme `-`, `_`, `!`.

### 2. Lancer la Stack (Modularité)
La stack utilise des **profils Docker Compose** pour économiser la RAM et le CPU de votre machine. 

**Option A : Configurer un profil persistant (Recommandé)**
Dans votre fichier `.env`, vous pouvez définir les profils que vous utilisez au quotidien :
```env
COMPOSE_PROFILES=db,api_tools,observability
```
Ensuite, un simple `docker compose up -d` lancera automatiquement vos outils favoris.

**Option B : Lancer des profils spécifiques à la volée**
```bash
# Exemple : Lancer les bases de données et les outils d'admin
docker compose --profile db --profile db_tools up -d

# Exemple : Gestion visuelle des conteneurs Docker
docker compose --profile devtools up -d

# Exemple : Ajouter la qualité de code temporairement
docker compose --profile code_quality up -d
```

---

## 🛠️ La Boîte à Outils (Profils & Services)

Voici la liste de tous les services embarqués, pourquoi ils sont là, et dans quels cas les utiliser.

### 🌐 Reverse Proxy (Core - *Toujours actif*)
- **Traefik** (`http://traefik.local`)
  - **Pourquoi ?** Il intercepte le trafic et le redirige vers vos conteneurs. Fini les conflits de ports (ex: `localhost:8080`, `localhost:8081`). Grâce à Traefik, chaque service obtient une belle URL personnalisée en `.local`.

### 🤖 Passerelle IA (`profile: ai`)
- **OmniRoute** (`http://omniroute.local`)
  - **Pourquoi ?** Passerelle IA (AI Gateway) et routeur d'API multi-modèles (LLM proxy/router).
  - **Cas d'usage :** Centraliser la gestion de vos clés d'API IA et alimenter vos assistants CLI et éditeurs (Claude Code, Cursor, Copilot, Codex, etc.) via un point d'entrée unique et maîtrisé en local. *(Nécessite le profil `db` avec Redis).*

### 🐳 Gestion & Surveillance Docker (`profile: ops` / `observability`)
- **Portainer** (`http://portainer.local`) *(aussi disponible avec `devtools`)*
  - **Pourquoi ?** Interface graphique web pour gérer vos conteneurs Docker (démarrer, arrêter, consulter les logs, inspecter les images) sans jamais taper une commande.
  - **Cas d'usage :** Surveiller l'état de votre stack en un coup d'œil, gérer les volumes et les images.
- **Dozzle** (`http://logs.local`) *(aussi disponible avec `observability`)*
  - **Pourquoi ?** Une interface web ultra-minimaliste et performante dédiée uniquement à la lecture des logs Docker en temps réel.
  - **Cas d'usage :** Déboguer une application Node.js ou Python qui tourne dans un autre conteneur sans avoir à taper `docker logs -f ...` dans un terminal pour chaque service.

### 📑 Bureau, Documents & Schémas (`profile: office` / `diagram`)
- **Stirling-PDF** (`http://pdf.local`)
  - **Pourquoi ?** L'application ultime de traitement et manipulation de fichiers PDF en self-hosted.
  - **Cas d'usage :** Fusionner, découper, compresser, signer, chiffrer, convertir ou appliquer de l'OCR sur vos documents PDF directement dans votre navigateur.
- **Excalidraw** (`http://draw.local`) *(disponible avec `office`, `diagram` ou `devtools`)*
  - **Pourquoi ?** Outil de schéma et tableau blanc virtuel collaboratif style "dessin à la main".
  - **Cas d'usage :** Modéliser des architectures système, dessiner des diagrammes de flux et concevoir des maquettes d'interface utilisateur.
- **Reactive Resume** (`http://resume.local`)
  - **Pourquoi ?** Un générateur de CV (Resume Builder) open-source, moderne, hautement personnalisable et respectueux de la vie privée.
  - **Cas d'usage :** Créer, éditer et exporter des CV professionnels élégants (format PDF), gérer plusieurs variantes de votre CV. *(Nécessite le profil `db` avec PostgreSQL et Redis).*

### 🗄️ Bases de Données (`profile: db` ou sous-profils: `db_postgres`, `db_mysql`, `db_redis`, `db_mongo`)
- **MySQL / PostgreSQL / MongoDB**
  - **Pourquoi ?** Les 3 bases de données relationnelles et NoSQL les plus utilisées sur le marché. Disponibles localement sur leurs ports par défaut (3306, 5432, 27017).
  - **Cas d'usage :** Héberger les données de vos applications backend Python, Node.js ou PHP. Vous pouvez lancer toutes les bases avec `--profile db`, ou cibler uniquement celle dont vous avez besoin avec `--profile db_postgres` (ou `db_mysql`, `db_redis`, `db_mongo`).
  - 💡 **Initialisation (`internal/postgres`) :** Ce dossier contient les scripts SQL d'initialisation exécutés au premier démarrage de PostgreSQL. On peut y placer ses propres fichiers `.sql` pour créer des tables ou des rôles automatiquement.
- **Redis** (`http://redis.local` pour RedisInsight)
  - **Pourquoi ?** Base de données en mémoire ultra-rapide.
  - **Cas d'usage :** Gestion du cache, files d'attente (Queues), gestion des sessions pour des API rapides.

### 🎛️ Administration BDD (`profile: db_tools`)
- **phpMyAdmin** (`http://phpmyadmin.local`) / **pgAdmin** (`http://pgadmin.local`) / **Mongo Express** (`http://mongo.local`) / **Adminer** (`http://adminer.local`)
  - **Pourquoi ?** Éviter d'avoir à installer des logiciels lourds comme DBeaver ou DataGrip sur votre machine. Ces interfaces web vous permettent de visualiser, modifier et exporter les données de vos bases de données d'un simple clic.

### ⚡ Outils API & Schémas (`profile: api_tools`)
- **Hoppscotch** (`http://api-tester.local`)
  - **Pourquoi ?** L'alternative open-source et ultra-rapide à Postman, accessible directement depuis le navigateur.
  - **Cas d'usage :** Tester vos routes d'API, sauvegarder des collections de requêtes, et partager des espaces de travail.
- **Swagger Editor** (`http://swagger.local`)
  - **Pourquoi ?** Éditeur visuel pour concevoir des spécifications OpenAPI (`openapi.json`). 
  - **Cas d'usage Magique :** Placez votre fichier d'API dans `./openapi/openapi.json`. Vous pourrez utiliser le bouton **Generate Client** pour générer automatiquement tout le code de communication (models, enums, requêtes) pour votre application Flutter/Dart, Python ou TypeScript !
- **Prism Mock API** (`http://mock-api.local`)
  - **Pourquoi ?** Créer un faux serveur backend (Mock) en une fraction de seconde basé sur votre spécification OpenAPI.
  - **Cas d'usage :** Les développeurs Front-end/Mobiles (ex: Flutter) n'ont pas besoin d'attendre que l'équipe Back-end ait terminé l'API. Prism répondra avec de fausses données (mocks) en respectant parfaitement le format attendu.
- **JSONJoy Builder** (`http://json-builder.local`) *(aussi disponible avec `devtools`)*
  - **Pourquoi ?** Interface visuelle pour créer, éditer et valider des schémas JSON Schema. Construite localement à partir des sources (image custom), sans aucune dépendance externe.
  - **Cas d'usage :** Concevoir et documenter la structure de vos données JSON, valider des documents JSON contre un schéma, ou générer des schémas à partir d'exemples.

### 🔍 Recherche (`profile: search`)
- **Meilisearch** (`http://search.local`)
  - **Pourquoi ?** Un moteur de recherche full-text open-source ultra performant, typeready et facile à utiliser (alternative à Algolia/ElasticSearch).
  - **Cas d'usage :** Implémenter une barre de recherche "instantanée" et tolérante aux fautes de frappe dans vos applications web/mobiles.

### 🛡️ Qualité de Code (`profile: code_quality`)
- **SonarQube** (`http://sonar.local`)
  - **Pourquoi ?** Le standard industriel pour l'analyse statique de code en continu.
  - **Cas d'usage :** Auditer la sécurité, détecter les bugs, mesurer la "dette technique" et valider la couverture de tests de vos projets Python, JavaScript ou Dart avant de fusionner votre code. *(Note : Service gourmand en RAM).*

### 📨 Messagerie & Événements (`profile: messaging`)
- **Mailpit** (`http://mail.local`)
  - **Pourquoi ?** Un faux serveur SMTP local.
  - **Cas d'usage :** Tester l'envoi d'e-mails depuis votre application (ex: "Mot de passe oublié") sans risquer de spammer de vrais utilisateurs. Les emails envoyés par votre code sont interceptés et visualisables sur l'interface web de Mailpit.
- **RabbitMQ** (`http://rabbitmq.local`)
  - **Pourquoi ?** Un broker de messages asynchrones.
  - **Cas d'usage :** Déléguer des tâches lourdes (ex: génération de PDF, envoi d'emails en masse) à des workers en arrière-plan (très utilisé avec Celery en Python).
- **Soketi** (`http://soketi.local`)
  - **Pourquoi ?** Serveur WebSockets compatible avec l'API Pusher.
  - **Cas d'usage :** Ajouter du temps réel à vos apps (chat en direct, notifications, rafraîchissement en temps réel) sans payer pour Pusher.

### 📦 Stockage S3 (`profile: storage`)
- **MinIO** (`http://minio.local`)
  - **Pourquoi ?** Le clone local parfait d'Amazon S3.
  - **Cas d'usage :** Si votre application doit uploader, stocker ou manipuler des fichiers/images/vidéos dans le Cloud, MinIO simule parfaitement S3. Vous utilisez les mêmes SDK (ex: Boto3 en Python) mais le stockage reste sur votre PC.

### 🤖 Automatisation (`profile: automation`)
- **n8n** (`http://n8n.local`)
  - **Pourquoi ?** L'alternative open-source et hébergeable de Zapier/Make.
  - **Cas d'usage :** Automatiser des workflows visuellement (ex: "Quand une ligne est ajoutée en base de données, envoyer un message sur Discord").

### 🐍 Data Science (`profile: data`)
- **JupyterLab** (`http://jupyter.local`)
  - **Pourquoi ?** L'environnement de référence pour l'analyse de données.
  - **Cas d'usage :** Explorer des jeux de données, faire de la manipulation Pandas, entrainer des modèles de Machine Learning, en conservant tous vos notebooks dans le dossier `./notebooks`.

### 🔄 Synchronisation P2P & Vaults (`profile: sync`)
- **Syncthing** (`http://syncthing.local`)
  - **Pourquoi ?** Une alternative open-source à Dropbox/Google Drive, qui synchronise vos fichiers en pair-à-pair (P2P) de manière chiffrée, sans passer par un cloud public.
  - **Cas d'usage (Standalone) :** Partager des fichiers de configuration, vos notes (Obsidian), ou synchroniser vos backups de base de données entre plusieurs de vos appareils.
  - **Cas d'usage "Vault Manager" :** En associant Syncthing à **KeePassXC**, vous obtenez un gestionnaire de mots de passe souverain et décentralisé. Parfait pour compartimenter les mots de passe de vos différents clients. 
  - 💡 **Astuce (Plusieurs dossiers) :** Syncthing mappe un dossier racine défini par `SYNCTHING_SYNC_DIR` dans le fichier `.env`. Pour synchroniser plusieurs projets, placez-les simplement dans ce dossier racine. Si vous devez cibler des dossiers éparpillés, créez un fichier `docker-compose.override.yml` pour y ajouter des volumes manuellement.
  - 📖 **Documentation dédiée :** [Lire le guide complet du Coffre-Fort Décentralisé](./docs/decentralized-vault.md) et utilisez `bash scripts/setup-vault-manager.sh` pour l'installation rapide.

### 📑 Bureau & Documents (`profile: office`)
- **Stirling-PDF** (`http://pdf.local`)
  - **Pourquoi ?** L'application ultime de traitement et manipulation de fichiers PDF en self-hosted.
  - **Cas d'usage :** Fusionner, découper, compresser, signer, chiffrer, convertir ou appliquer de l'OCR sur vos documents PDF directement dans votre navigateur, de manière totalement privée et hors cloud.
- **Reactive Resume** (`http://resume.local`)
  - **Pourquoi ?** Un générateur de CV (Resume Builder) open-source, moderne, hautement personnalisable et respectueux de la vie privée.
  - **Cas d'usage :** Créer, éditer et exporter des CV professionnels élégants (format PDF), gérer plusieurs variantes de votre CV et synchroniser vos données. *(Nécessite le profil `db` actif avec PostgreSQL).*

### 🕵️‍♂️ OSINT & Cybersécurité (`profile: osint`)
- **Flowsint** (`http://flowsint.local`)
  - **Pourquoi ?** Plateforme open-source d'investigation graphique (OSINT). Elle permet de cartographier visuellement des entités (nom de domaine, IP, e-mail, réseaux sociaux) et de découvrir les liens cachés via des scripts automatisés (enrichers).
  - **Cas d'usage (Ops / Sécurité) :** 
    - *Cartographie :* Lancer des scripts sur votre domaine pour découvrir le Shadow IT, les sous-domaines, et vérifier la sécurité.
    - *Investigation :* Analyser les IP/e-mails suspects en cas de brute-force, ou vérifier les fuites de données de vos utilisateurs.
  - **Cas d'usage (Dev Fullstack - Modèle d'Architecture) :**
    - Étudier une architecture moderne et scalable : Frontend SPA (graphes), Backend FastAPI, bases de données hybrides (PostgreSQL + **Neo4j** pour les graphes), et tâches asynchrones via Celery.
    - Un système de plugins propre pour les "enrichers".
  - > ⚠️ **ATTENTION (Ressources) :** Ce profil lance **Neo4j** (très gourmand en RAM) ainsi qu'un worker Celery et une API. Assurez-vous d'avoir au moins 2-3 Go de RAM disponibles avant d'activer ce profil. Ne l'activez que lorsque vous en avez besoin.

---

## 🔌 Connexions depuis vos propres applications

Pour que vos applications (front/back) puissent communiquer avec ces outils, voici les ports par défaut.

> 💡 **COMMENT CONNECTER VOS PROPRES CONTENEURS (Ex: Votre API métier) ?**
> Vous avez deux solutions pour que vos propres projets Docker accèdent à ces bases de données :
> 
> **1. Via le réseau interne Docker (Recommandé 🚀)**
> Déclarez le réseau de la Dev Stack dans le `docker-compose.yml` de votre propre projet pour pouvoir utiliser le **Host interne** (ex: `mysql`, `postgres`).
> ```yaml
> networks:
>   devnet:
>     name: devstack_devnet # Le vrai nom du réseau créé par ce repo
>     external: true
> ```
> *(Assurez-vous ensuite d'ajouter `networks: - devnet` à votre service).*
> 
> **2. Via la machine hôte (Si vous lancez vos scripts hors de Docker)**
> Utilisez simplement `localhost` ou `127.0.0.1` pour pointer sur les ports exposés par la Dev Stack sur votre machine hôte. *(Astuce : Depuis un conteneur isolé, vous pouvez utiliser `host.docker.internal` à la place de `localhost`).*

| Service | Host local (Machine hôte) | Host interne (Réseau Docker `devnet`) | Port |
|---|---|---|---|
| MySQL | `localhost` | `mysql` | 3306 |
| PostgreSQL | `localhost` | `postgres` | 5432 |
| MongoDB | `localhost` | `mongo` | 27017 |
| Redis | `localhost` | `redis` | 6379 |
| Mailpit SMTP | `localhost` | `mailpit` | 1025 |
| RabbitMQ AMQP | `localhost` | `rabbitmq` | 5672 |
| MinIO API | `localhost` | `minio` | 9000 |
| Meilisearch | `localhost` | `meilisearch` | 7700 |

*(Les identifiants par défaut sont définis dans votre fichier `.env` via `GLOBAL_USER` et `GLOBAL_PASSWORD`)*

---

## 🛑 Commandes utiles au quotidien

```bash
# Arrêter toute la stack proprement
docker compose stop

# Tout supprimer (⚠️ détruit les conteneurs et les réseaux, mais les volumes de BDD restent)
docker compose down

# Tout supprimer (🚨 DANGER : détruit aussi les volumes et toutes les bases de données !)
docker compose down -v

# Relancer un service spécifique qui a planté
docker compose restart traefik

# Suivre les logs d'un service spécifique en ligne de commande (si vous n'utilisez pas Dozzle)
docker compose logs -f n8n
```

## 🔒 Confidentialité & Partage
- Ce dépôt est conçu pour être partagé.
- Le fichier `.gitignore` masque automatiquement le fichier `.env` contenant vos secrets ainsi que les données persistantes et volumes locaux.