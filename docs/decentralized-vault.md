# Gestionnaire de Coffre-Fort Décentralisé (KeePassXC + Syncthing)

Bienvenue dans le guide du gestionnaire de mots de passe décentralisé. Cette documentation décrit comment mettre en place une solution robuste, souveraine et hautement sécurisée pour gérer vos mots de passe clients sans dépendre d'un service Cloud (Vendor Lock-in).

> [!NOTE]
> **Syncthing est un outil généraliste de synchronisation.** Le gestionnaire de mots de passe n'est qu'**un seul cas d'usage**. En tant que service autonome (`profile: sync`), Syncthing peut synchroniser n'importe quel type de données (fichiers de configuration, notes Obsidian, sauvegardes de bases de données, etc.) de manière chiffrée de pair-à-pair entre vos différentes machines (PC, Smartphone, Serveur) sans passer par un cloud public.

---

## 🏗️ Concept Architectural

La sécurité est bâtie sur deux piliers :
1. **Chiffrement local "Zero-Knowledge" (KeePassXC)** : Vos données ne sont jamais stockées en clair. Tout est chiffré dans des fichiers `.kdbx` locaux sur votre machine via KeePassXC.
2. **Synchronisation P2P chiffrée (Syncthing)** : Syncthing tourne de manière isolée dans un conteneur Docker. Il va synchroniser en continu vos fichiers `.kdbx` avec vos autres appareils (ex: téléphone, ordinateur portable) de manière décentralisée (P2P), sans passer par un serveur tiers centralisé (fini les fuites de type LastPass).

---

## 🚀 Utilisation du Script d'Installation

Pour vous simplifier la vie, un script interactif automatisé est inclus dans le projet. Il crée le répertoire sécurisé, vérifie les prérequis, installe les logiciels manquants et configure votre environnement.

```bash
# 1. Assurez-vous d'être à la racine du projet docker_dev_stack
cd /chemin/vers/docker_dev_stack

# 2. Exécutez le script d'installation
bash scripts/setup-vault-manager.sh
```

**Que fait ce script ?**
- Détecte votre système (Linux ou macOS).
- Vous demande le chemin du répertoire où stocker vos coffres (par défaut `~/Documents/Vaults_Clients`).
- Crée ce dossier et lui applique des droits d'accès stricts (`chmod 700`).
- Ajoute ce chemin à votre fichier `.env` (`SYNCTHING_SYNC_DIR`).
- Démarre le conteneur `syncthing` (s'il ne l'est pas).
- Vous propose d'installer **KeePassXC** si ce n'est pas déjà fait.

Une fois terminé, vous pourrez accéder à l'interface de Syncthing via [http://syncthing.local](http://syncthing.local) (ou le port 8384).

---

## 💼 Workflow Recommandé pour Freelance (Isolement par Client)

En tant que freelance ou agence, mélanger les accès de tous vos clients dans un seul coffre-fort est une très mauvaise pratique (risque de fuite transversale).

> [!IMPORTANT]
> **Règle d'or : Un client = Un fichier `.kdbx`**

1. Ouvrez KeePassXC.
2. Cliquez sur `Créer une nouvelle base de données`.
3. Sauvegardez le fichier dans votre dossier synchronisé (ex: `~/Documents/Vaults_Clients/Client_Acme.kdbx`).
4. Protégez-le par un mot de passe maître robuste, unique à ce client.
5. Syncthing détectera immédiatement le nouveau fichier et le synchronisera sur vos autres appareils approuvés.

Ce cloisonnement vous protège : si un mot de passe maître est compromis, seul le coffre de ce client est impacté.

---

## 🤝 Smooth Handover (Fin de Mission)

La fin d'une prestation (Offboarding) est souvent compliquée quand les mots de passe sont partagés dans un gestionnaire d'équipe payant (1Password, Bitwarden). Avec cette méthode, la réversibilité est totale.

**Procédure de livraison :**
1. Changez le mot de passe maître du coffre `Client_Acme.kdbx` pour un mot de passe temporaire généré aléatoirement.
2. Transmettez le fichier `.kdbx` au client (par email, clé USB ou dépôt sécurisé).
3. Transmettez le mot de passe maître temporaire par un **canal de communication différent** (ex: Signal, SMS, ou via un lien à usage unique comme Bitwarden Send).
4. Le client peut alors ouvrir le fichier avec KeePass (Windows), KeePassXC (Mac/Linux), KeePassDX (Android) ou Strongbox (iOS).
5. (Optionnel) Une fois que le client vous confirme la bonne réception et le changement du mot de passe maître de son côté, supprimez le fichier de votre dossier `Vaults_Clients`. Syncthing répliquera cette suppression, nettoyant ainsi vos accès.

Aucun Vendor Lock-in, 100% de transparence, et une hygiène de sécurité irréprochable.
