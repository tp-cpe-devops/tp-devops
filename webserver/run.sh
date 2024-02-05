# Configuration de postgres
docker network create app-network > /dev/null;
docker stop webserver > /dev/null;
docker rm webserver > /dev/null;
docker build -t webserver . --no-cache > /dev/null && 
docker run -d -p 7070:80 --network app-network --name webserver webserver > /dev/null &&
echo "Webserver is running ..."
