docker network create app-network;
docker stop postgres &&
docker rm postgres && 
docker build -t postgres . --no-cache && 
docker run -it -p 5432:5432 --name postgres postgres