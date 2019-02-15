# Ceros DevOps Code Challenge - Infrastructure Portion
This directory contains all of the infrastructure as code (IaC) files necessary to set up the ceros-ski application, IAM, networking and storage.

## Directory Structure
* [application.tf](application.tf) - contains all of the infrastructure for ECS running on EC2
* [iam.tf](iam.tf) - contains all identity and access management files
* [main.tf](main.tf) - contains terraform configuration, cloud provider, and globally applicable modules
* [storage.tf](storage.tf) - contains S3 and database files necessary for storage
* [variables.tf](variables.tf) - contains variables that are used across the infrastructure

## Considerations
* This code runs 3 Docker containers of ceros-ski scheduled across 2 EC2 instances to provide high availability. 
    * Number of instances and containers can be modified in [application.tf](application.tf).
* This cluster uses AWS Application Load Balancers (ALBs) which is configured for load balancing across the cluster. Configuration for the load balancer is found in [application.tf](application.tf).

## Future Development & Technical Debt
- Version this infrastructure in a separate repository (useful for immutable deployments of infrastructure from development to production)
    - Figured this to be overkill for a simple project like this. For more robust infrastructure, versioning via Github tags is a good option.
- Public/Private Subnets
    - Staying within the bounds of the free tier, I don't find it necessary at this time to set up a NAT for the private subnets
- HTTPS certificates 
    - Seeing that there's no FQDN that we have control of for this challenge and we cannot generate one for amazonaws.com, even with an HTTPS certificate we would get certificate errors in the browser that must be bypassed in order to access the application 
- Encrypting Terraform state & lock (S3 & DynamoDB)
    - AWS Key Management Service (KMS) which DynamoDB uses for encryption at rest is not free
