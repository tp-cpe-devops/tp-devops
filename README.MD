# TP partie 01

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

On construit en plusieurs étapes est utilisée pour optimiser la taille de l'image Docker finale.
On sépare les phases de construction de l'application de la phase d'exécution. On réduit la taille de l'image finale en n'incluant que les artefacts nécessaires à l'exécution de l'application, sans conserver les outils de construction ni les fichiers temporaires.
