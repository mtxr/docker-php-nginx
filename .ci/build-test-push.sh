#!/bin/bash

export TAG=`if [ "$TRAVIS_BRANCH" == "master" ]; then echo "latest"; else echo $TRAVIS_BRANCH ; fi`

docker build -t $REPO:$COMMIT . && \
docker images && \
docker run --name ${REPO//[^[:alnum:]]/} -d -p 8888:80 --rm $REPO:$COMMIT /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf && \
sleep 5 && \
curl "http://localhost:8888/" && \
docker rm -f ${REPO//[^[:alnum:]]/} && \
docker tag $REPO:$COMMIT $REPO:$TAG && \
( ( [ "$TAG" == "latest" ] && echo "Publishing latest..." ) || docker tag $REPO:$COMMIT $REPO:$TAG-v$TRAVIS_BUILD_NUMBER ) && \
docker rmi $REPO:$COMMIT && \
docker login -u="$DOCKER_USER" -p="$DOCKER_PASS" && \
docker push $REPO
