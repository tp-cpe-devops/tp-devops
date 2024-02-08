# Configuration du backend
docker network create app-network > /dev/null;
docker stop backend-2 > /dev/null;
docker rm backend-2 > /dev/null;
docker build -t backend-2 . --no-cache > /dev/null && 
docker run -d -p 8090:8090 --network app-network --name backend-2 backend-2 > /dev/null &&
echo "Backend 2 is running ..."
