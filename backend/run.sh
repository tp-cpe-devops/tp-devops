# Configuration de postgres
docker network create app-network > /dev/null;
docker stop backend > /dev/null;
docker rm backend > /dev/null;
docker build -t backend . --no-cache > /dev/null && 
docker run -d -p 5432:5432 --name backend backend > /dev/null &&
echo "Backend is running ..."
    