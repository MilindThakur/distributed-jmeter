#!/bin/bash

#slave count parameter
SLAVE=$3

#test script parameters
THREADCOUNT=${1-1}
filename=$2

#building docker images and configuring directories
docker-compose stop && docker-compose rm -f
docker build -t jmeter-base jmeter-base
docker-compose build && docker-compose up -d && docker-compose scale master=1 slave=$SLAVE
SLAVE_IP=$(docker inspect -f '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq) | grep slave | awk -F' ' '{print $2}' | tr '\n' ',' | sed 's/.$//')
echo "SLAVE_IP=" $SLAVE_IP
WDIR=`docker exec -it master /bin/pwd | tr -d '\r'`
mkdir -p results
NAME=$(basename $filename)
NAME="${NAME%.*}"
eval "docker cp $filename master:$WDIR/scripts/"

#run the test based on the above config in non-gui distributed mode & log results
docker ps
docker ps -q | xargs docker inspect --format '{{ .Id }} - {{ .Name }} - {{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}'
eval "docker exec -it master /bin/bash -c 'mkdir $NAME && cd $NAME && ../bin/jmeter -Jserver.rmi.ssl.disable=true -n -t ../$filename -l $WDIR/$NAME/logfile.jtl -R$SLAVE_IP -Gthreads=$THREADCOUNT'"
eval "docker cp master:$WDIR/$NAME results/"

#stop and remove master, slave instances
#docker-compose stop && docker-compose rm -f