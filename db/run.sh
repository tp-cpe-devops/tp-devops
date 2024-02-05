# Configuration de postgres
docker network create app-network > /dev/null;
docker stop postgres > /dev/null &&
docker rm postgres > /dev/null && 
docker build -t postgres . --no-cache > /dev/null && 
docker run -d -p 5432:5432 --name postgres postgres > /dev/null &&
echo "Postgres is running ..."

# Configuration d'adminer
docker stop adminer > /dev/null;
docker rm adminer > /dev/null; 
docker run -d --link postgres:db -p 8080:8080 --name adminer adminer 1> /dev/null
echo "Adminer is running ..."