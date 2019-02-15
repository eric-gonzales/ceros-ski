#!/bin/bash

# use a simple UNIX timestamp to version the app
# todo implement a more robust (semantic) versioning system
CI_TIMESTAMP=`date +%s`

# download and unzip the program
curl -o ceros-ski-master.zip https://s3.amazonaws.com/ceros-dev-code-challenge/ceros-ski.zip
if [ -d "ceros-ski-master " ]; then
    rm -Rf ceros-ski-master
fi
unzip -o ceros-ski-master.zip && rm -Rf ceros-ski-master.zip

# log into ecr
$(aws ecr get-login --no-include-email --region us-east-1)

# build and tag the image
docker build -t ceros-ski .
docker tag ceros-ski:latest 638635720737.dkr.ecr.us-east-1.amazonaws.com/ceros-evaluation:latest
docker tag ceros-ski:latest 638635720737.dkr.ecr.us-east-1.amazonaws.com/ceros-evaluation:${CI_TIMESTAMP}

# docker can only push one tag at a time so we must use two `docker push` commands https://github.com/docker/cli/pull/1021
docker push 638635720737.dkr.ecr.us-east-1.amazonaws.com/ceros-evaluation:latest
docker push 638635720737.dkr.ecr.us-east-1.amazonaws.com/ceros-evaluation:${CI_TIMESTAMP}

# used for easy blue/green deployment with the newest image
# https://github.com/silinternational/ecs-deploy
ecs-deploy -c ceros-evaluation -n ceros-evaluation-service -i 638635720737.dkr.ecr.us-east-1.amazonaws.com/ceros-evaluation:${CI_TIMESTAMP}
