# Ceros DevOps Code Challenge - Deployment Portion
This directory contains all of the files necessary to deploy the ceros-ski application to the ECS cluster. 

> Please ensure that the underlying infrastructure has been deployed before running these scripts!

## Structure 

This directory contains a: 

* [Dockerfile](Dockerfile) which is a simple Node.js container that runs the ceros-ski app
* [deploy.sh](deploy.sh) script which pulls down the latest ceros-ski from S3, dockerizes it, and triggers a blue/green deployment on ECS all in a handy script!

## Deploying new code

1. Install [ecs-deploy](https://github.com/silinternational/ecs-deploy) (if its not already installed)
2. Run `sh deploy.sh`

## Future Development & Technical Debt
- Semantic versioning is not implemented for docker containers
    - For the scope of this project, creating scripts for semantic versioning seems to be a bit much to take on for now. Instead the decision was made to simply use a Unix timestamp to serially version docker containers. 
- `ecs-deploy` can do more than just update the image for the deployment. Expanding the shell script to take arguments for updating tags, updating task definitions, etc. would be worthwhile.
