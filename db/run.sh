docker network create app-network &&
docker rmi postgres &&
docker build -t postgres . --no-cache && 
docker run -it -p 5432:5432 --name postgres postgres
