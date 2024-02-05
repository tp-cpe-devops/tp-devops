FROM postgres:14.1-alpine

ENV POSTGRES_DB=db \
   POSTGRES_USER=usr \
   POSTGRES_PASSWORD=pwd

COPY ./init-db-scripts/ /docker-entrypoint-initdb.d/

EXPOSE 5432

# Installation de packages supplémentaires (facultatif)
# Utiliser apk, le gestionnaire de paquets d'Alpine, pour une installation légère
RUN apk add --no-cache \
   bash \
   vim \
   tzdata \
   && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
   && echo "Europe/Paris" > /etc/timezone \
   && apk del tzdata

EXPOSE 5432
VOLUME ["/var/lib/postgresql/data"]
