# TP partie 1

> **1-1 Documentez les éléments essentiels de votre conteneur de base de données : commandes et Dockerfile.**

## **Dockerfile**

```Dockerfile
# Image de base
FROM postgres:14.1-alpine
```

```Dockerfile
# Variables d'environnement
ENV POSTGRES_DB=db \
    POSTGRES_USER=usr \
    POSTGRES_PASSWORD=pwd
```

```Dockerfile
# Copie des scripts d'initialisation
COPY ./init-db-scripts/ /docker-entrypoint-initdb.d/
```

```Dockerfile
# Exposition du port
EXPOSE 5432
```

```Dockerfile
# Installation de packages, configuration du fuseau horaire et suppression de tzdata après installation
RUN apk add --no-cache \
    bash \
    vim \
    tzdata \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && echo "Europe/Paris" > /etc/timezone \
    && apk del tzdata
```

```Dockerfile
# Changement des autorisations et lien symbolique
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /
```

```Dockerfile
# Définition du volume pour persistance des données
VOLUME ["/var/lib/postgresql/data"]
```

## **Script run.sh**

### PostgreSQL

```bash
# Création d'un réseau Docker
docker network create app-network > /dev/null;
```

```bash
# Arrêt et suppression du conteneur PostgreSQL si existant
docker stop postgres > /dev/null;
docker rm postgres > /dev/null;
```

```bash
# Construction de l'image PostgreSQL avec le Dockerfile
docker build -t postgres . --no-cache > /dev/null
```

```bash
# Démarrage du conteneur PostgreSQL en mode détaché avec le nom 'postgres' et exposition du port 5432
docker run -d -p 5432:5432 --name postgres postgres > /dev/null
```

### Adminer

```bash
# Arrêt et suppression du conteneur Adminer si existant
docker stop adminer > /dev/null;
docker rm adminer > /dev/null;
```

```bash
# Démarrage du conteneur Adminer en mode détaché, lié au conteneur PostgreSQL, et exposition du port 9090
docker run -d --link postgres:db -p 9090:8080 --name adminer adminer > /dev/null
```

> **1-2 Pourquoi avons-nous besoin d'une construction en plusieurs étapes ? Et expliquez chaque étape de ce fichier docker.**

On construit en plusieurs étapes pour optimiser la taille de l'image Docker finale.
On sépare les phases de construction de l'application de la phase d'exécution. On réduit la taille de l'image finale en n'incluant que les artefacts nécessaires à l'exécution de l'application, sans conserver les outils de construction ni les fichiers temporaires.

> **1-3 Documenter les commandes les plus importantes de docker-compose.**

`docker-compose up` : Démarre les services\
`docker-compose down` : Arrêter et supprimer les ressources\
`docker-compose ps` : Afficher l'état des services\
`docker-compose logs` : Afficher les journaux\
`docker-compose exec` : Exécuter une commande dans unservice\
`docker-compose build` : Construire les images\
`docker-compose pull` : Télécharger les images\
`docker-compose restart` : Redémarrer les services

> **1-4 Documenter votre fichier docker-compose.**

- `version: '3.7'` : Spécifie la version de la syntaxe Docker Compose utilisée
- `services : Section définissant les services`
  - `backend`
    - `build: backend/.` : Construit l'image du backend à partir du dossier backend/.
    - `container_name: backend` : Nomme le conteneur "backend"
    - `networks: app-network` : Connecte le conteneur au réseau "app-network"
    - `depends_on: database, httpd` : Permet d'attendre que les services database et httpd soient lancés avant de démarrer le backend
  - `database`
    - `ports: "5432:5432"` : Map le port 5432 de l'hôte au port 5432 du conteneur
    - `build: db/.` : Construit l'image de la base de données à partir du dossier db/.
    - `container_name: postgres` : Nomme le conteneur "postgres"
    - `networks: app-network` : Connecte le conteneur au réseau "app-network"
  - `httpd`
    - `ports: "80:80"` : Map le port 80 de l'hôte au port 80 du conteneur
    - `build: webserver/.` : Construit l'image du serveur web à partir du dossier webserver/.
    - `container_name: webserver` : Nomme le conteneur "webserver"
    - `networks: app-network` : Connecte le conteneur au réseau "app-network"
  - `networks` : Section définissant le réseau "app-network"
    - `app-network` : Un réseau défini pour connecter les services

> **1-5 Documentez vos commandes de publication et les images publiées dans dockerhub.**

`docker login -u <usr>` puis entrer un access token : Connexion à Docker Hub\
`docker compose build` : Construction des images Docker\
`docker image ls` : Voir la liste des images Docker\
`docker tag <img_name>:<version> <usr>/<img_name>:<version>` : Tag de l'image\
`docker push <usr>/<img_name>:<version>` : Publication de l'image\

# TP partie 2

> **2-1 Qu'est ce que testcontainers ?**

_Testcontainers_ est une bibliothèque Java qui rationalise les tests d'intégration avec des instances légères et jetables de bases de données, de navigateurs web et d'autres services dans des conteneurs Docker. On peut ainsi faire des tests d'intégrations facilement en contactant des instances de containers de manière rapide et légère dans l'instance de CI.

**Avantages:**

```
* Simplifier de la gestion des containers
* Faciliter les scénarios de tests
* Accélérer des cycles de dvp.
* Améliorer de la fiabilité des tests pour les applications ayant des dépendances externes
```

> **2-2 Documentez vos configurations Github Actions**

**Définit le nom du workflow**

```yml
name: CI devops 2023
```

---

**Indique que ce workflow sera déclenché quand on push sur main**

```yml
on:
  push:
    branches: main
```

---

**Définit un job nommé "Test de l'application Spring" qui s'exécute sur `Ubuntu 22.04`**\
**Commence la liste des étapes à exécuter pour ce travail**

```yml
jobs:
  test-backend:
    name: "Test de l'application Spring"
    runs-on: ubuntu-22.04
    steps:
```

---

**Récupère le code du référentiel GitHub dans l'environnement de travail**

```yml
- uses: actions/checkout@v2.5.0
```

---

**Utilise l'action `setup-java@v3` pour configurer `JDK 17` avec la distribution `Temurin`**

```yml
- name: Set up JDK 17
  uses: actions/setup-java@v3
  with:
    java-version: "17"
    distribution: "temurin"
```

---

**Sélection du répertoire de travail `./backend/simpleapi`**\
**Exécute la commande Maven `mvn clean verify` pour nettoyer, compiler et tester le projet**

```yml
- name: Build and test with Maven
  working-directory: ./backend/simpleapi
  run: mvn clean verify
```

---

**Définit un job nommé "Construction et publication de l'image Docker" qui dépend du travail test-backend et s'exécute sur `Ubuntu 22.04`**\
**Commence la liste des étapes à exécuter pour ce travail**

```yml
build-and-push-docker-image:
  name: "Build and push Docker image"
  needs: test-backend
  runs-on: ubuntu-22.04
  steps:
```

---

**Utilise l'action `checkout@v2.5.0` pour récupérer à nouveau le code source du référentiel GitHub**

```yml
- name: Checkout code
  uses: actions/checkout@v2.5.0
```

---

**Exécute la commande `docker login` avec les noms d'utilisateur et les tokens d'accès.**

```yml
- name: Login to DockerHub
  run: docker login -u ${{ secrets.DOCKERHUB_USERNAME }} -p ${{ secrets.DOCKERHUB_TOKEN }}
```

---

**Utilise l'action `docker/build-push-action@v3` pour construire et pousser l'image Docker à partir du répertoire `./backend`**\
**L'image est taguée avec le nom d'utilisateur de DockerHub provenant des secrets et la version `1.0.0`**\
**L'image n'est publiée que si la référence GitHub est `refs/heads/main`**

```yml
- name: Build image and push backend
  uses: docker/build-push-action@v3
  with:
    context: ./backend
    tags: ${{secrets.DOCKERHUB_USERNAME}}/devops-backend:1.0.0
    push: ${{ github.ref == 'refs/heads/main' }}
```

---

**Utilise l'action docker/build-push-action@v3 pour construire et pousser l'image Docker à partir du répertoire `./db`**\
**L'image est taguée avec le nom d'utilisateur de DockerHub provenant des secrets et la version `1.0.0`**\
**L'image n'est publiée que si la référence GitHub est `refs/heads/main`**

```yml
- name: Build image and push database
  uses: docker/build-push-action@v3
  with:
    context: ./db
    tags: ${{secrets.DOCKERHUB_USERNAME}}/devops-database:1.0.0
    push: ${{ github.ref == 'refs/heads/main' }}
```

---

**Utilise l'action docker/build-push-action@v3 pour construire et pousser l'image Docker à partir du répertoire `./webserver`**\
**L'image est taguée avec le nom d'utilisateur de DockerHub provenant des secrets et la version `1.0.0`**\
**L'image n'est publiée que si la référence GitHub est `refs/heads/main`**

```yml
- name: Build image and push httpd
  uses: docker/build-push-action@v3
  with:
    context: ./webserver
    tags: ${{secrets.DOCKERHUB_USERNAME}}/devops-httpd:1.0.0
    push: ${{ github.ref == 'refs/heads/main' }}
```

---

> **2-3 Documentez la configuration de votre quality gate**

![Quality gate board](./docs/qg.png)

Chacun de nos critères doit prétendre à une note qui ne doit pas être inférieure à A.

La couverture de test doit être supérieur ou égale à 80% et le taux de duplication doit être inférieure à 3%.

Si une de ces conditions n'est pas respéctée, l'étape de quality gate dans la CI échoue.

# TP partie 3

> **3-1 Documenter votre inventaire et vos commandes de base**

Inventaire (``setup.yml``) :
```yml
all:
 vars:
   ansible_user: centos
   ansible_ssh_private_key_file: .ansible_key
 children:
   prod:
     hosts: centos@baptiste.gris.takima.cloud
```

Commandes de base : 
- Test de ping :

  ```
  ansible all -i inventories/setup.yml -m ping
  ```
  Teste la connectivité à tous les hôtes répertoriés dans le fichier d'inventaire en utilisant le module ping.

- Récupération distrib. OS :

  ```
  ansible all -i inventories/setup.yml -m setup -a "filter=ansible_distribution*"
  ```
  Collecte des facts sur les hôtes répertoriés dans le fichier d'inventaire. Elle les filter pour récupérer des informations relatives à la distribution du système d'exploitation.

- Gestion des Packages (Yum) - Suppression du Serveur HTTP Apache :

  ```
  ansible all -i inventories/setup.yml -m ping
  ```
  Supprime le serveur httpd de tous les hôtes répertoriés dans le fichier d'inventaire en utilisant le module yum avec le nom du package et son état spécifiés.

> **3-2 Documenter votre playbook**

``playbook.yml`` :
```yml
- hosts: all
  gather_facts: false
  become: true

  roles:
  - docker

  tasks:
  - name: Test connection
    ping:
```

Ce playbook Ansible est utilisé pour configurer des hôtes cibles pour exécuter des conteneurs Docker :

- `hosts: all`: Signifie que les tâches dans ce playbook seront exécutées sur tous les hôtes spécifiés dans l'inventaire Ansible.

- `gather_facts: false`: Désactive la collecte automatique des facts sur les hôtes.

- `become: true`: Active les privilèges super-utilisateur

- `roles`: Rôles à exécuter (ici le rôle docker)

- `tasks`: Tâches du playbook

  - `name: Test connection`: Nom donné à la tâche
  
  - `ping`: Action Ansible de ping

---

``roles/docker/tasks/main.yml`` :
```yml
# tasks file for roles/docker
- name: Install device-mapper-persistent-data
  yum:
    name: device-mapper-persistent-data
    state: latest

- name: Install lvm2
  yum:
    name: lvm2
    state: latest

- name: add repo docker
  command:
    cmd: sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

- name: Install Docker
  yum:
    name: docker-ce
    state: present

- name: Install python3
  yum:
    name: python3
    state: present

- name: Install docker with Python 3
  pip:
    name: docker
    executable: pip3
  vars:
    ansible_python_interpreter: /usr/bin/python3

- name: Make sure Docker is running
  service: name=docker state=started
  tags: docker
```

**Install device-mapper-persistent-data** : Installe "device-mapper-persistent-data" avec yum

**Install lvm2** : Installe "lvm2" avec yum

**Add repo docker** : Utilise la commande shell pour ajouter le référentiel Docker à partir de l'URL spécifiée

**Install Docker** : Installe "docker-ce" avec yum

**Install python3** : Installe "python3" avec yum

**Install docker with Python 3** : Installe "docker" avec Python 3

**Make sure Docker is running** : Démarre le service Docker et assure qu'il est en cours d'exécution

> **3-3 Documenter votre configuration des tasks de docker_container**

### ``app`` :
#### Tâche 1 : Arrêter et supprimer le container Docker
- Cette tâche utilise le module `docker_container` pour gérer les conteneurs Docker.
- Le nom du conteneur est spécifié à l'aide de la variable `app_name`.
- L'état du conteneur est défini sur "absent", ce qui signifie qu'il sera arrêté et supprimé s'il existe.
- L'option `ignore_errors` est définie sur `true`, ce qui signifie que les erreurs éventuelles seront ignorées.

#### Tâche 2 : Tirer et lancer le container Docker
- Cette tâche utilise également le module `docker_container` pour gérer les conteneurs Docker.
- Le nom du conteneur est spécifié à l'aide de la variable `app_name`.
- L'image Docker à utiliser est spécifiée à l'aide de la variable `docker_image`.
- L'état du conteneur est défini sur `started`, ce qui signifie que le conteneur sera démarré.
- L'option `recreate` est définie sur `true`, ce qui signifie que le conteneur sera recréé s'il existe déjà.
- L'option `pull` est définie sur `true`, ce qui signifie que l'image Docker sera récupérée si elle n'est pas déjà présente localement.
- Le mode réseau du conteneur est spécifié à l'aide de la variable `network`.
- Les ports exposés sont spécifiés à l'aide de la variable `port_expose`.
- Les variables d'environnement pour le conteneur sont spécifiées pour définir le mot de passe, l'utilisateur et la base de données PostgreSQL.

#### Tâche 3 : Afficher le message de confirmation
- Cette tâche utilise le module `debug` pour afficher un message.
- Le message affiché indique que le conteneur spécifié par `app_name` est en cours d'exécution.
---
### ``database`` :
#### Tâche 1 : Arrêter et supprimer le container Docker
- Cette tâche utilise le module `docker_container` pour gérer les conteneurs Docker.
- Le nom du conteneur est spécifié à l'aide de la variable `app_name`.
- L'état du conteneur est défini sur "absent", ce qui signifie qu'il sera arrêté et supprimé s'il existe.
- L'option `ignore_errors` est définie sur `true`, ce qui signifie que les erreurs éventuelles seront ignorées.

#### Tâche 2 : Tirer et lancer le container Docker
- Cette tâche utilise également le module `docker_container` pour gérer les conteneurs Docker.
- Le nom du conteneur est spécifié à l'aide de la variable `app_name`.
- L'image Docker à utiliser est spécifiée à l'aide de la variable `docker_image`.
- L'état du conteneur est défini sur "started", ce qui signifie que le conteneur sera démarré.
- L'option `recreate` est définie sur `true`, ce qui signifie que le conteneur sera recréé s'il existe déjà.
- L'option `pull` est définie sur `true`, ce qui signifie que l'image Docker sera récupérée si elle n'est pas déjà présente localement.
- Le mode réseau du conteneur est spécifié à l'aide de la variable `network`.
- Les ports exposés sont spécifiés à l'aide de la variable `port_expose`.
- Les variables d'environnement pour le conteneur sont spécifiées pour définir le mot de passe, l'utilisateur et la base de données PostgreSQL.

#### Tâche 3 : Afficher le message de confirmation
- Cette tâche utilise le module `debug` pour afficher un message.
- Le message affiché indique que le conteneur spécifié par `app_name` est en cours d'exécution.
---
### ``docker`` :
#### Tâche 1 : Installer device-mapper-persistent-data
- Cette tâche utilise le module `yum` pour installer des packages via le gestionnaire de paquets yum.
- Le package `device-mapper-persistent-data` est installé avec l'état `latest`, ce qui signifie qu'il sera mis à jour s'il est déjà installé.

#### Tâche 2 : Installer lvm2
- Cette tâche utilise également le module `yum` pour installer des packages via yum.
- Le package `lvm2` est installé avec l'état `latest`, ce qui garantit qu'il est à jour.

#### Tâche 3 : Ajouter le dépôt Docker
- Cette tâche utilise le module `command` pour exécuter une commande shell.
- La commande `sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo` ajoute le dépôt Docker au système.

#### Tâche 4 : Installer Docker
- Cette tâche utilise à nouveau le module `yum` pour installer le package Docker Community Edition (`docker-ce`).
- L'état est défini sur `present`, ce qui garantit que le package sera installé s'il ne l'est pas déjà.

#### Tâche 5 : Installer python3
- Cette tâche utilise le module `yum` pour installer Python 3.
- L'état est défini sur `present`, ce qui garantit que Python 3 sera installé s'il ne l'est pas déjà.

#### Tâche 6 : Installer docker avec Python 3
- Cette tâche utilise le module `pip` pour installer le module Python `docker`.
- L'exécutable `pip3` est spécifié pour installer le module pour Python 3.
- La variable `ansible_python_interpreter` est définie sur `/usr/bin/python3` pour assurer que le bon interpréteur Python est utilisé.

#### Tâche 7 : S'assurer que Docker est en cours d'exécution
- Cette tâche utilise le module `service` pour s'assurer que le service Docker est démarré.
- Le tag `docker` est ajouté pour permettre de cibler spécifiquement cette tâche lors de l'exécution avec des tags.

#### Tâche 8 : Vérifier si déjà connecté à Docker
- Cette tâche utilise le module `command` pour exécuter la commande `docker info` et enregistre le résultat dans la variable `docker_info`.
- Les erreurs sont ignorées avec `ignore_errors: true`, ce qui signifie que si la commande échoue, cela ne provoquera pas une erreur dans l'exécution du playbook.

#### Tâche 9 : Se connecter à DockerHub
- Cette tâche utilise le module `docker_login` pour se connecter à DockerHub.
- Les identifiants DockerHub sont spécifiés à l'aide des variables `docker_hub_username` et `docker_hub_password`.
---
### ``frontend`` :
#### Tâche 1 : Arrêter et supprimer le container Docker
- Cette tâche utilise le module `docker_container` pour gérer les conteneurs Docker.
- Le nom du conteneur est spécifié à l'aide de la variable `app_name`.
- L'état du conteneur est défini sur "absent", ce qui signifie qu'il sera arrêté et supprimé s'il existe.
- L'option `ignore_errors` est définie sur `true`, ce qui signifie que les erreurs éventuelles seront ignorées.

#### Tâche 2 : Tirer et lancer le container Docker
- Cette tâche utilise également le module `docker_container` pour gérer les conteneurs Docker.
- Le nom du conteneur est spécifié à l'aide de la variable `app_name`.
- L'image Docker à utiliser est spécifiée à l'aide de la variable `docker_image`.
- L'état du conteneur est défini sur "started", ce qui signifie que le conteneur sera démarré.
- L'option `recreate` est définie sur `true`, ce qui signifie que le conteneur sera recréé s'il existe déjà.
- L'option `pull` est définie sur `true`, ce qui signifie que l'image Docker sera récupérée si elle n'est pas déjà présente localement.
- Le mode réseau du conteneur est spécifié à l'aide de la variable `network`.
- Les ports exposés sont spécifiés à l'aide de la variable `port_expose`.

#### Tâche 3 : Afficher le message de confirmation
- Cette tâche utilise le module `debug` pour afficher un message.
- Le message affiché indique que le conteneur spécifié par `app_name` est en cours d'exécution.
---
### ``network`` :
#### Tâche 1 : Créer un réseau
- Cette tâche utilise le module `docker_network` pour créer un réseau Docker.
- Le nom du réseau est spécifié à l'aide de la variable `docker_network`.
---
### ``proxy`` :
#### Tâche 1 : Arrêter et supprimer le container Docker
- Cette tâche utilise le module `docker_container` pour gérer les conteneurs Docker.
- Le nom du conteneur est défini en dur comme "httpd".
- L'état du conteneur est défini sur "absent", ce qui signifie qu'il sera arrêté et supprimé s'il existe.
- L'option `ignore_errors` est définie sur `true`, ce qui signifie que les erreurs éventuelles seront ignorées.

#### Tâche 2 : Tirer et lancer le container Docker
- Cette tâche utilise également le module `docker_container` pour gérer les conteneurs Docker.
- Le nom du conteneur est défini en dur comme "httpd".
- L'image Docker à utiliser est spécifiée à l'aide de la variable `docker_image`.
- L'état du conteneur est défini sur "started", ce qui signifie que le conteneur sera démarré.
- L'option `recreate` est définie sur `true`, ce qui signifie que le conteneur sera recréé s'il existe déjà.
- L'option `pull` est définie sur `true`, ce qui signifie que l'image Docker sera récupérée si elle n'est pas déjà présente localement.
- Le mode réseau du conteneur est spécifié à l'aide de la variable `network`.
- Les ports exposés sont spécifiés à l'aide de la variable `port_expose`.

#### Tâche 3 : Afficher le message de confirmation
- Cette tâche utilise le module `debug` pour afficher un message.
- Le message affiché indique que le conteneur spécifié par `app_name` est en cours d'exécution.
---
### ``setup.yml`` :
```yml
all:
  vars:
    ansible_user: centos
    ansible_ssh_private_key_file: .ansible_key
    postgres_password: pwd
    postgres_user: usr
    postgres_db: db
    network: app-network
  children:
    prod:
      hosts: centos@baptiste.gris.takima.cloud
```

#### Variables globales
- Les variables globales sont définies sous la section `vars`.
  - `ansible_user`: Définit l'utilisateur Ansible à utiliser lors de la connexion aux hôtes, défini comme `centos`.
  - `ansible_ssh_private_key_file`: Définit le chemin vers le fichier de clé privée SSH à utiliser pour la connexion aux hôtes, défini comme `.ansible_key`.
  - `postgres_password`: Définit le mot de passe de la base de données PostgreSQL, défini comme `pwd`.
  - `postgres_user`: Définit le nom d'utilisateur de la base de données PostgreSQL, défini comme `usr`.
  - `postgres_db`: Définit le nom de la base de données PostgreSQL, défini comme `db`.
  - `network`: Définit le nom du réseau Docker à utiliser, défini comme `app-network`.

#### Groupes d'hôtes
- Les hôtes sont regroupés sous la section `children`.
  - Le groupe `prod` est défini pour les serveurs de production.
  - L'hôte spécifique `centos@baptiste.gris.takima.cloud` est spécifié sous le groupe `prod`.
    - `centos`: Nom d'utilisateur pour la connexion SSH.
    - `baptiste.gris.takima.cloud`: Nom d'hôte ou adresse IP de l'hôte
