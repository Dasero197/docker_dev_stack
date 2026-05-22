# 🐳 Dev Stack — L'Environnement de Développement Ultime

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

# Exemple : Ajouter la qualité de code temporairement
docker compose --profile code_quality up -d
```

---

## 🛠️ La Boîte à Outils (Profils & Services)

Voici la liste de tous les services embarqués, pourquoi ils sont là, et dans quels cas les utiliser.

### 🌐 Reverse Proxy (Core - *Toujours actif*)
- **Traefik** (`http://traefik.local`)
  - **Pourquoi ?** Il intercepte le trafic et le redirige vers vos conteneurs. Fini les conflits de ports (ex: `localhost:8080`, `localhost:8081`). Grâce à Traefik, chaque service obtient une belle URL personnalisée en `.local`.

### 🗄️ Bases de Données (`profile: db`)
- **MySQL / PostgreSQL / MongoDB**
  - **Pourquoi ?** Les 3 bases de données relationnelles et NoSQL les plus utilisées sur le marché. Disponibles localement sur leurs ports par défaut (3306, 5432, 27017).
  - **Cas d'usage :** Héberger les données de vos applications backend Python, Node.js ou PHP.
- **Redis** (`http://redis.local` pour RedisInsight)
  - **Pourquoi ?** Base de données en mémoire ultra-rapide.
  - **Cas d'usage :** Gestion du cache, files d'attente (Queues), gestion des sessions pour des API rapides.

### 🎛️ Administration BDD (`profile: db_tools`)
- **phpMyAdmin** (`http://phpmyadmin.local`) / **pgAdmin** (`http://pgadmin.local`) / **Mongo Express** (`http://mongo.local`) / **Adminer** (`http://adminer.local`)
  - **Pourquoi ?** Éviter d'avoir à installer des logiciels lourds comme DBeaver ou DataGrip sur votre machine. Ces interfaces web vous permettent de visualiser, modifier et exporter les données de vos bases de données d'un simple clic.

### ⚡ Outils API (`profile: api_tools`)
- **Hoppscotch** (`http://api-tester.local`)
  - **Pourquoi ?** L'alternative open-source et ultra-rapide à Postman, accessible directement depuis le navigateur.
  - **Cas d'usage :** Tester vos routes d'API, sauvegarder des collections de requêtes, et partager des espaces de travail.
- **Swagger Editor** (`http://swagger.local`)
  - **Pourquoi ?** Éditeur visuel pour concevoir des spécifications OpenAPI (`openapi.json`). 
  - **Cas d'usage Magique :** Placez votre fichier d'API dans `./openapi/openapi.json`. Vous pourrez utiliser le bouton **Generate Client** pour générer automatiquement tout le code de communication (models, enums, requêtes) pour votre application Flutter/Dart, Python ou TypeScript !
- **Prism Mock API** (`http://mock-api.local`)
  - **Pourquoi ?** Créer un faux serveur backend (Mock) en une fraction de seconde basé sur votre spécification OpenAPI.
  - **Cas d'usage :** Les développeurs Front-end/Mobiles (ex: Flutter) n'ont pas besoin d'attendre que l'équipe Back-end ait terminé l'API. Prism répondra avec de fausses données (mocks) en respectant parfaitement le format attendu.

### 🔍 Recherche (`profile: search`)
- **Meilisearch** (`http://search.local`)
  - **Pourquoi ?** Un moteur de recherche full-text open-source ultra performant, typeready et facile à utiliser (alternative à Algolia/ElasticSearch).
  - **Cas d'usage :** Implémenter une barre de recherche "instantanée" et tolérante aux fautes de frappe dans vos applications web/mobiles.

### 📊 Observabilité et Logs (`profile: observability`)
- **Dozzle** (`http://logs.local`)
  - **Pourquoi ?** Une interface web ultra-minimaliste et performante dédiée uniquement à la lecture des logs Docker en temps réel.
  - **Cas d'usage :** Déboguer une application Node.js ou Python qui tourne dans un autre conteneur sans avoir à taper `docker logs -f ...` dans un terminal pour chaque service.

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
- Le fichier `.gitignore` masque automatiquement le fichier `.env` (vos mots de passe) et les données internes des bases de données (`mysql_data`, etc.).
- Ne commitez **jamais** votre fichier `.env` !

*Bon dev !* 🚀
