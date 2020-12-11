DATE=20201212
TAG=scriptmoney/blog:${DATE}
DOMAIN=45.32.251.65
docker build -t ${TAG} .
docker run --name blog -p 80:80 --env BASEURL=${DOMAIN} --rm -d ${TAG}
docker push {TAG}