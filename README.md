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
Avant de démarrer la stack, copiez et renommez le fichier d'exemple `.env.example` en `.env`, puis sélectionnez les profils à activer et configurez au minimum les variables essentielles listées ci-dessous.

Commandes cross-platform (choisissez la ligne adaptée à votre shell) :

```bash
# POSIX (Linux / macOS / WSL / Git Bash)
cp .env.example .env
```

```powershell
# PowerShell (Windows / PowerShell Core)
Copy-Item .env.example .env
```

```python
# Python fallback (si Python installé)
python - <<'PY'
import shutil
shutil.copyfile('.env.example', '.env')
print('.env created')
PY
```

Ensuite, éditez `./.env` et ajoutez (ou modifiez) les profils que vous souhaitez utiliser quotidiennement via la variable `COMPOSE_PROFILES`, par exemple :

```env
COMPOSE_PROFILES=db,api_tools,devtools,office
```

Configurez au minimum ces variables dans `./.env` (valeurs de fallback par défaut si variables spécifiques laissées vides) :

- `GLOBAL_USER=`
- `GLOBAL_PASSWORD=`
- `GLOBAL_DB_NAME=`
- `DOMAIN_SUFFIX=local` (ou tout autre suffixe de votre choix) 
- `TIMEZONE=Africa/Porto-Novo`

Ces valeurs servent de fallback par défaut. Si un service a besoin de variables spécifiques (ex: `POSTGRES_USER`, `REDIS_PASSWORD`), rendez-vous dans la section correspondante du fichier `.env` et ajustez-les avant de lancer la stack.

Une fois le fichier `.env` prêt, lancez le script d'ajout des domaines locaux :

```bash
sudo bash setup-hosts.sh
```

Remarque importante : si vous choisissez de démarrer des profils à la volée (ex: `docker compose --profile hoppscotch up -d`) sans préremplir `COMPOSE_PROFILES` dans `.env`, vous pouvez tout à fait démarrer les services. Cependant, `setup-hosts.sh` n'ajoutera pas automatiquement les domaines associés à ces services, car il analyse `COMPOSE_PROFILES` pour déterminer quels domaines ajouter au fichier `hosts`. Pour que `setup-hosts.sh` configure correctement les domaines, mettez d'abord les profils désirés dans `COMPOSE_PROFILES` dans `./.env`.

> 💡 **Astuce (Mots de passe avec caractères spéciaux) :** Évitez absolument d'utiliser les caractères `@`, `%`, `:`, et `/` dans vos mots de passe (`GLOBAL_PASSWORD`). 
> Certains outils (comme Python Alembic utilisé par Flowsint) plantent s'ils voient un `%` dans l'URL de la base de données, rendant l'encodage URL impossible. Privilégiez des mots de passe longs avec des lettres, chiffres, et des caractères sûrs comme `-`, `_`, `!`.

### 2. Lancer la Stack (Modularité)
La stack utilise des **profils Docker Compose** pour économiser la RAM et le CPU de votre machine. 

**Option A : Configurer un profil persistant (Recommandé)**
Dans votre fichier `.env`, vous pouvez définir les profils que vous utilisez au quotidien :
```env
COMPOSE_PROFILES=db,api_tools,devtools,office
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

**Démarrer un service précis**

Chaque service dispose maintenant d'un profil individuel. Utilisez ces profils pour lancer uniquement un service précis sans activer toute sa catégorie.

Exemples :

```bash
# Démarrer uniquement PostgreSQL
docker compose --profile postgres up -d

# Démarrer MySQL et Redis uniquement
docker compose --profile mysql --profile redis up -d
```

les profils individuels peuvent etre aussi utilisés dans le fichier `.env` pour un démarrage persistant.

---

## 🧭 Portail central d’accès — Homepage

La stack intègre maintenant un portail d’accueil nommé **Homepage**, conçu comme un **service core** de la stack, au même titre que **Traefik**. Il n’est donc pas rattaché à un profil optionnel et est lancé automatiquement avec le fichier Compose principal.

- **URL d’accès :** `http://home.<suffix>` (ex: `http://home.local` si `DOMAIN_SUFFIX=local`)
- **Rôle :** centraliser l’accès à vos outils, services web et dashboards.
- **Auto-discovery :** Homepage est compatible avec l’auto-discovery Docker. Grâce aux labels `homepage.*` ajoutés aux services, il détecte automatiquement les applications exposées et les affiche dans l’interface sans configuration manuelle à chaque ajout.
- **Personnalisation :** la configuration est dans `internal/configs/homepage/` et suit la structure officielle de Homepage. La référence de configuration est disponible dans la documentation officielle : https://gethomepage.dev/configs/
- **Cas d’usage :** ouvrir rapidement un service, garder un aperçu visuel de l’environnement, et ajouter des widgets de monitoring, de status ou de métriques directement dans le dashboard.
- **Comportement Compose :** contrairement aux services de profil, Homepage est lancé par défaut dans un `docker compose up -d`, et il reste présent lorsque vous démarrez la stack avec des profils (`docker compose --profile db ... up -d`), car il fait partie du cœur de l’infrastructure.

> 💡 Homepage est particulièrement utile quand la stack grandit : un trou de mémoire par rapport à l'url d'un de vos services; vous avez un point d’entrée unique et personnalisable, prêt à être enrichi selon vos usages et regroupant tout ce qu'il faut savoir.

---

## 📊 Monitoring système — Glances

La stack embarque aussi **Glances**, un outil de surveillance système léger et très complet.

- **URL d’accès :** `http://glances.<suffix>` (ex: `http://glances.local` si `DOMAIN_SUFFIX=local`)
- **Rôle :** monitorer en temps réel la machine hôte : CPU, RAM, disques, réseau, températures, processus, conteneurs Docker, etc.
- **Utilisation combinée :** Homepage peut afficher des widgets Glances pour voir les métriques directement dans le dashboard principal, sans quitter le portail.
- **Utilisation autonome :** Glances peut être utilisé seul si vous voulez un suivi système dédié, sans dépendre du portail d’accueil.

Cette combinaison est idéale pour un setup complet :
- `Homepage` = portail central d’accès et vue d’ensemble des services
- `Glances` = monitoring système détaillé et statistiques machine

---

## 🛠️ La Boîte à Outils (Profils & Services)

Voici la liste de tous les services embarqués, pourquoi ils sont là, et dans quels cas les utiliser.

### 🌐 Reverse Proxy (Core - *Toujours actif*)
- **Traefik** (`http://traefik.<suffix>`)
  - **Pourquoi ?** Il intercepte le trafic et le redirige vers vos conteneurs. Fini les conflits de ports (ex: `localhost:8080`, `localhost:8081`). Grâce à Traefik, chaque service obtient une belle URL personnalisée en `.<suffix>`.

### 🤖 Passerelle IA (`profile: ai`)
- **OmniRoute** (`http://omniroute.<suffix>`)
  - **Pourquoi ?** Passerelle IA (AI Gateway) et routeur d'API multi-modèles (LLM proxy/router).
  - **Cas d'usage :** Centraliser la gestion de vos clés d'API IA et alimenter vos assistants CLI et éditeurs (Claude Code, Cursor, Copilot, Codex, etc.) via un point d'entrée unique et maîtrisé en local. *(Nécessite le profil `db` avec Redis).*

### 🐳 Gestion & Surveillance Docker (`profile: ops`)
- **Homepage** (`http://home.<suffix>`)
  - **Pourquoi ?** Portail central de la stack, listant les services disponibles et permettant d’ouvrir rapidement chacun d’entre eux depuis un tableau de bord unique.
  - **Cas d'usage :** Centraliser les accès aux outils de développement, naviguer entre services sans mémoriser les URLs, et profiter de widgets de monitoring pour avoir un aperçu rapide du système.
- **Portainer** (`http://portainer.<suffix>`) *(aussi disponible avec `devtools`)*
  - **Pourquoi ?** Interface graphique web pour gérer vos conteneurs Docker (démarrer, arrêter, consulter les logs, inspecter les images) sans jamais taper une commande.
  - **Cas d'usage :** Surveiller l'état de votre stack en un coup d'œil, gérer les volumes et les images.
- **Dozzle** (`http://logs.<suffix>`)
  - **Pourquoi ?** Une interface web ultra-minimaliste et performante dédiée uniquement à la lecture des logs Docker en temps réel.
  - **Cas d'usage :** Déboguer une application Node.js ou Python qui tourne dans un autre conteneur sans avoir à taper `docker logs -f ...` dans un terminal pour chaque service.
- **Glances** (`http://glances.<suffix>`)
  - **Pourquoi ?** Outil de surveillance système complet pour suivre CPU, RAM, disque, réseau, température, processus et conteneurs.
  - **Cas d'usage :** Suivi machine en temps réel, prévention de blocages, diagnostic de performances, et intégration directe dans Homepage via widgets.

### 📑 Bureau, Documents & Schémas (`profile: office`)
- **Stirling-PDF** (`http://pdf.<suffix>`)
  - **Pourquoi ?** L'application ultime de traitement et manipulation de fichiers PDF en self-hosted.
  - **Cas d'usage :** Fusionner, découper, compresser, signer, chiffrer, convertir ou appliquer de l'OCR sur vos documents PDF directement dans votre navigateur.
- **Excalidraw** (`http://draw.<suffix>`) *(disponible avec `office` ou `devtools`)*
  - **Pourquoi ?** Outil de schéma et tableau blanc virtuel collaboratif style "dessin à la main".
  - **Cas d'usage :** Modéliser des architectures système, dessiner des diagrammes de flux et concevoir des maquettes d'interface utilisateur.
- **Reactive Resume** (`http://resume.<suffix>`)
  - **Pourquoi ?** Un générateur de CV (Resume Builder) open-source, moderne, hautement personnalisable et respectueux de la vie privée.
  - **Cas d'usage :** Créer, éditer et exporter des CV professionnels élégants (format PDF), gérer plusieurs variantes de votre CV. *(Nécessite le profil `db` avec PostgreSQL et Redis).*

### 🗄️ Bases de Données (`profile: db` ou sous-profils: `postgres`, `mysql`, `redis`, `mongo`)
- **MySQL / PostgreSQL / MongoDB**
  - **Pourquoi ?** Les 3 bases de données relationnelles et NoSQL les plus utilisées sur le marché. Disponibles localement sur leurs ports par défaut (3306, 5432, 27017).
  - **Cas d'usage :** Héberger les données de vos applications backend Python, Node.js ou PHP. Vous pouvez lancer toutes les bases avec `--profile db`, ou cibler uniquement celle dont vous avez besoin avec `--profile postgres` (ou `mysql`, `redis`, `mongo`).
  - 💡 **Initialisation (`internal/postgres`) :** Ce dossier contient les scripts SQL d'initialisation exécutés au premier démarrage de PostgreSQL. On peut y placer ses propres fichiers `.sql` pour créer des tables ou des rôles automatiquement.
  Afin d'evier de tourner plusieurs instance de postgres vu que plusieurs autres services de la stack utilisent postgres on a un script d'initialisation qui va créer les bases de données et les utilisateurs pour chaque service qui en a besoin. 

- **Redis** (`http://redis.<suffix>` pour RedisInsight)
  - **Pourquoi ?** Base de données en mémoire ultra-rapide.
  - **Cas d'usage :** Gestion du cache, files d'attente (Queues), gestion des sessions pour des API rapides.
  

### 🎛️ Administration BDD (`profile: db_tools`)
- **phpMyAdmin** (`http://phpmyadmin.<suffix>`) / **pgAdmin** (`http://pgadmin.<suffix>`) / **Mongo Express** (`http://mongo.<suffix>`) / **Adminer** (`http://adminer.<suffix>`)
  - **Pourquoi ?** Éviter d'avoir à installer des logiciels lourds comme DBeaver ou DataGrip sur votre machine. Ces interfaces web vous permettent de visualiser, modifier et exporter les données de vos bases de données d'un simple clic.

### ⚡ Outils API & Schémas (`profile: api_tools`)
- **Hoppscotch** (`http://api-tester.<suffix>`)
  - **Pourquoi ?** L'alternative open-source et ultra-rapide à Postman, accessible directement depuis le navigateur.
  - **Cas d'usage :** Tester vos routes d'API, sauvegarder des collections de requêtes, et partager des espaces de travail.
- **Swagger Editor** (`http://swagger.<suffix>`)
  - **Pourquoi ?** Éditeur visuel pour concevoir des spécifications OpenAPI (`openapi.json`). 
  - **Cas d'usage Magique :** Placez votre fichier d'API dans `./openapi/openapi.json`. Vous pourrez utiliser le bouton **Generate Client** pour générer automatiquement tout le code de communication (models, enums, requêtes) pour votre application Flutter/Dart, Python ou TypeScript !
- **Prism Mock API** (`http://mock-api.<suffix>`)
  - **Pourquoi ?** Créer un faux serveur backend (Mock) en une fraction de seconde basé sur votre spécification OpenAPI.
  - **Cas d'usage :** Les développeurs Front-end/Mobiles (ex: Flutter) n'ont pas besoin d'attendre que l'équipe Back-end ait terminé l'API. Prism répondra avec de fausses données (mocks) en respectant parfaitement le format attendu.
- **JSONJoy Builder** (`http://json-builder.<suffix>`) *(aussi disponible avec `devtools`)*
  - **Pourquoi ?** Interface visuelle pour créer, éditer et valider des schémas JSON Schema. Construite localement à partir des sources (image custom), sans aucune dépendance externe.
  - **Cas d'usage :** Concevoir et documenter la structure de vos données JSON, valider des documents JSON contre un schéma, ou générer des schémas à partir d'exemples.

### 🔍 Recherche (`profile: search`)
- **Meilisearch** (`http://search.<suffix>`)
  - **Pourquoi ?** Un moteur de recherche full-text open-source ultra performant, typeready et facile à utiliser (alternative à Algolia/ElasticSearch).
  - **Cas d'usage :** Implémenter une barre de recherche "instantanée" et tolérante aux fautes de frappe dans vos applications web/mobiles.

### 🛡️ Qualité de Code (`profile: code_quality`)
- **SonarQube** (`http://sonar.<suffix>`)
  - **Pourquoi ?** Le standard industriel pour l'analyse statique de code en continu.
  - **Cas d'usage :** Auditer la sécurité, détecter les bugs, mesurer la "dette technique" et valider la couverture de tests de vos projets Python, JavaScript ou Dart avant de fusionner votre code. *(Note : Service gourmand en RAM).*

### 📨 Messagerie & Événements (`profile: messaging`)
- **Mailpit** (`http://mail.<suffix>`)
  - **Pourquoi ?** Un faux serveur SMTP local.
  - **Cas d'usage :** Tester l'envoi d'e-mails depuis votre application (ex: "Mot de passe oublié") sans risquer de spammer de vrais utilisateurs. Les emails envoyés par votre code sont interceptés et visualisables sur l'interface web de Mailpit.
- **RabbitMQ** (`http://rabbitmq.<suffix>`)
  - **Pourquoi ?** Un broker de messages asynchrones.
  - **Cas d'usage :** Déléguer des tâches lourdes (ex: génération de PDF, envoi d'emails en masse) à des workers en arrière-plan (très utilisé avec Celery en Python).
- **Soketi** (`http://soketi.<suffix>`)
  - **Pourquoi ?** Serveur WebSockets compatible avec l'API Pusher.
  - **Cas d'usage :** Ajouter du temps réel à vos apps (chat en direct, notifications, rafraîchissement en temps réel) sans payer pour Pusher.

### 📦 Stockage S3 (`profile: storage`)
- **MinIO** (`http://minio.<suffix>`)
  - **Pourquoi ?** Le clone local parfait d'Amazon S3.
  - **Cas d'usage :** Si votre application doit uploader, stocker ou manipuler des fichiers/images/vidéos dans le Cloud, MinIO simule parfaitement S3. Vous utilisez les mêmes SDK (ex: Boto3 en Python) mais le stockage reste sur votre PC.

### 🤖 Automatisation (`profile: automation`)
- **n8n** (`http://n8n.<suffix>`)
  - **Pourquoi ?** L'alternative open-source et hébergeable de Zapier/Make.
  - **Cas d'usage :** Automatiser des workflows visuellement (ex: "Quand une ligne est ajoutée en base de données, envoyer un message sur Discord").

### 🐍 Data Science (`profile: data`)
- **JupyterLab** (`http://jupyter.<suffix>`)
  - **Pourquoi ?** L'environnement de référence pour l'analyse de données.
  - **Cas d'usage :** Explorer des jeux de données, faire de la manipulation Pandas, entrainer des modèles de Machine Learning, en conservant tous vos notebooks dans le dossier `./notebooks`.

### 🔄 Synchronisation P2P & Vaults (`profile: sync`)
- **Syncthing** (`http://syncthing.<suffix>`)
  - **Pourquoi ?** Une alternative open-source à Dropbox/Google Drive, qui synchronise vos fichiers en pair-à-pair (P2P) de manière chiffrée, sans passer par un cloud public.
  - **Cas d'usage (Standalone) :** Partager des fichiers de configuration, vos notes (Obsidian), ou synchroniser vos backups de base de données entre plusieurs de vos appareils.
  - **Cas d'usage "Vault Manager" :** En associant Syncthing à **KeePassXC**, vous obtenez un gestionnaire de mots de passe souverain et décentralisé. Parfait pour compartimenter les mots de passe de vos différents clients. 
  - 💡 **Astuce (Plusieurs dossiers) :** Syncthing mappe un dossier racine défini par `SYNCTHING_SYNC_DIR` dans le fichier `.env`. Pour synchroniser plusieurs projets, placez-les simplement dans ce dossier racine. Si vous devez cibler des dossiers éparpillés, créez un fichier `docker-compose.override.yml` pour y ajouter des volumes manuellement.
  - 📖 **Documentation dédiée :** [Lire le guide complet du Coffre-Fort Décentralisé](./docs/decentralized-vault.md) et utilisez `bash scripts/setup-vault-manager.sh` pour l'installation rapide.

### 📑 Bureau & Documents (`profile: office`)
- **Stirling-PDF** (`http://pdf.<suffix>`)
  - **Pourquoi ?** L'application ultime de traitement et manipulation de fichiers PDF en self-hosted.
  - **Cas d'usage :** Fusionner, découper, compresser, signer, chiffrer, convertir ou appliquer de l'OCR sur vos documents PDF directement dans votre navigateur, de manière totalement privée et hors cloud.
- **Reactive Resume** (`http://resume.<suffix>`)
  - **Pourquoi ?** Un générateur de CV (Resume Builder) open-source, moderne, hautement personnalisable et respectueux de la vie privée.
  - **Cas d'usage :** Créer, éditer et exporter des CV professionnels élégants (format PDF), gérer plusieurs variantes de votre CV et synchroniser vos données. *(Nécessite le profil `db` actif avec PostgreSQL).*

### 🕵️‍♂️ OSINT & Cybersécurité (`profile: osint`)
  - **Pourquoi ?** Plateforme open-source d'investigation graphique (OSINT). Elle permet de cartographier visuellement des entités (nom de domaine, IP, e-mail, réseaux sociaux) et de découvrir les liens cachés via des scripts automatisés (enrichers).
  - **Cas d'usage (Ops / Sécurité) :** 
    - *Cartographie :* Lancer des scripts sur votre domaine pour découvrir le Shadow IT, les sous-domaines, et vérifier la sécurité.
    - *Investigation :* Analyser les IP/e-mails suspects en cas de brute-force, ou vérifier les fuites de données de vos utilisateurs.
  - **Cas d'usage (Dev Fullstack - Modèle d'Architecture) :**
    - Étudier une architecture moderne et scalable : Frontend SPA (graphes), Backend FastAPI, bases de données hybrides (PostgreSQL + **Neo4j** pour les graphes), et tâches asynchrones via Celery.
    - Un système de plugins propre pour les "enrichers".
  - > ⚠️ **ATTENTION (Ressources) :** Ce profil lance **Neo4j** (très gourmand en RAM) ainsi qu'un worker Celery et une API. Assurez-vous d'avoir au moins 2-3 Go de RAM disponibles avant d'activer ce profil. Ne l'activez que lorsque vous en avez besoin.
  
    - **Remarque importante :** Le groupe Flowsint est étroitement couplé et **n'est pas conçu pour être lancé partiellement**. Ils partagent des schémas, des secrets et des dépendances partagées ; pour éviter des erreurs d'initialisation et des conflits de ressources, utilisez le profil individuel `flowsint` pour démarrer l'ensemble cohérent des services Flowsint.
    
      Exemple :

      ```bash
      # Lancer Flowsint (API + App + Celery + Neo4j)
      docker compose --profile flowsint up -d
      ```


## 🗃️ Profils disponibles (résumé)

Utilisez `docker compose --profile <profile>` pour démarrer une catégorie complète ou un service individuel. Ci-dessous les profils de catégorie et les profils individuels correspondants.

- **Services core**
  - `Homepage` : service permanent, sans profil, lancé avec le compose principal comme Traefik.
- **Profils de catégorie**
  - `db` : regroupe `postgres`, `mysql`, `redis`, `mongo_db`
  - `db_tools` : phpMyAdmin (`phpmyadmin`), pgAdmin (`pgadmin`), Mongo Express (`mongo_express`), Adminer (`adminer`)
  - `ai` : OmniRoute (`omniroute`)
  - `ops` : Portainer (`portainer`), Dozzle (`dozzle`), Glances (`glances`)
  - `office` : Stirling-PDF (`stirling_pdf`), Reactive Resume (`reactive_resume`), Excalidraw (`excalidraw`)
  - `api_tools` : Hoppscotch (`hoppscotch`), Swagger Editor (`swagger_editor`), Prism Mock (`prism_mock`), JSONJoy Builder (`jsonjoy_builder`)
  - `messaging` : Mailpit (`mailpit`), RabbitMQ (`rabbitmq`), Soketi (`soketi`)
  - `storage` : MinIO (`minio`)
  - `automation` : n8n (`n8n`)
  - `data` : JupyterLab (`jupyter`)
  - `search` : Meilisearch (`meilisearch`)
  - `code_quality` : SonarQube (`sonarqube`)
  - `osint` : Flowsint (utiliser le profil individuel `flowsint` pour démarrer l'ensemble Flowsint)
  - `sync` : Syncthing (`syncthing`)
  - `devtools` : regroupe plusieurs outils d'administration et dev

- **Profils individuels (démarrent une unité applicative complète)**
  - Databases : `mysql`, `postgres`, `redis`, `mongo`
  - Messaging : `mailpit`, `rabbitmq`, `soketi`
  - API & Dev : `hoppscotch`, `swagger_editor`, `prism_mock`, `jsonjoy_builder`, `omniroute`
  - Admin DB : `phpmyadmin`, `pgadmin`, `mongo_express`, `adminer`
  - Office : `stirling_pdf`, `excalidraw`, `reactive_resume`
  - Ops : `portainer`, `dozzle`
  - OSINT : `flowsint`
  - Search / Storage / Sync / Data / QA : `meilisearch`, `minio`, `syncthing`, `jupyter`, `sonarqube`

### Mapping DB → profils individuels

Pour garantir un démarrage cohérent quand vous lancez un profil individuel, les services de base de données incluent désormais les profils des services qui en dépendent. Exemples :

- `postgres` démarre avec : `hoppscotch`, `n8n`, `pgadmin`, `reactive_resume`, `sonarqube`, `flowsint`
- `mysql` démarre avec : `phpmyadmin`, `adminer`
- `redis` démarre avec : `omniroute`, `reactive_resume`, `flowsint`
- `mongo` démarre avec : `mongo_express`

Ainsi `docker compose --profile hoppscotch up -d` va inclure `postgres` automatiquement.

Exemples :

```bash
# Démarrer toutes les bases de données
docker compose --profile db up -d

# Démarrer uniquement Hoppscotch
docker compose --profile hoppscotch up -d

# Démarrer MinIO et Jupyter
docker compose --profile minio --profile jupyter up -d
```


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