# Ceros DevOps Code Challenge
This challenge takes a provided Node.js application (eg. [ceros-ski](https://s3.amazonaws.com/ceros-dev-code-challenge/ceros-ski.zip)), wraps it in a docker container, spins up some EC2 servers and deploys the containers to the servers. The application is web accessible afterwards. 

Multiple ceros-ski app containers are deployed and can be configured in the [infrastructure as code](infrastructure/README.md). A deploy script is created to allow for updates to ceros-ski to be [deployed with no downtime](deploy/README.md) (eg. blue/green deployment.)

## Overview

The following acceptance criteria has been completed for this challenge: 

- All infrastructure follows the AWS free-tier offerings
- Infrastructure (EC2 servers, ECS, etc.) is defined in Terraform
- Services are securely configured and security concerns are handled
- Ceros-ski application is wrapped in a docker container
- Ceros-ski application is accessible from the web once deployed
- Process of deploying the ceros-ski app container to ec2 is documented (see below)
- Code is clearly documented
- Decisions to take on tech debt are documented and explained

## How to Deploy

There's two major considerations when deploying - the infrastructure and then the application. 

### Infrastructure
Infrastructure should be set up first so that we can have an ECR repository for Docker and ECS/EC2 for the application to run on. It's a simple step to set up:

From this directory `cd infrastructure && terraform apply`

> See the [infrastructure README](infrastructure/README.md) for additional information!

### Application Deployment

Once the AWS infrastructure is set up, deployments are easy via a simple shell script.

1. The deploy script utilizes [ecs-deploy](https://github.com/silinternational/ecs-deploy) so ensure that is installed beforehand
2. From this directory: `cd deploy && sh deploy.sh` - this will automatically pull down the latest ceros-ski from S3, dockerize it, and trigger a blue/green deployment on ECS

> See the [deploy README](deploy/README.md) for additional information!
