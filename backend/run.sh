# Configuration du backend
docker network create app-network > /dev/null;
docker stop backend > /dev/null;
docker rm backend > /dev/null;
docker build -t backend . --no-cache > /dev/null && 
docker run -d -p 8080:8080 --network app-network --name backend backend > /dev/null &&
echo "Backend is running ..."
