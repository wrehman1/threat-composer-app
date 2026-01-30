# ECS Project | Threat Composer Application 
<!-- Project badges -->
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)
![Docker](https://img.shields.io/badge/Container-Docker-blue)
![AWS ECS](https://img.shields.io/badge/AWS-ECS-orange)


## Table of Contents:
- Description
- Repository Structure
- Architecture Diagram
- Reproduction Steps
- Infrastructure (Terraform)
- CI/CD Pipelines

## Project Description: 

Welcome to the Threat Modelling Tool, a containerised web application designed for teams to collaboratively identify and manage security threats. Built for the cloud, this project leverages AWS ECS Fargate for serverless container orchestration, enabling scalable, consistent deployments across all environments.

The application runs inside private subnets, ensuring that core services are isolated from public access. All inbound traffic is routed through an Application Load Balancer (ALB) in a public subnet, enforcing security through obscurity by minimising surface area and exposure. HTTPS is enforced via AWS Certificate Manager (ACM), with Route53 and Cloudflare DNS handling secure and reliable domain resolution.

Infrastructure is fully automated with Terraform and GitHub Actions, enabling repeatable, versioned deployments using Infrastructure as Code (IaC). Docker images are built and pushed to Amazon ECR, then deployed securely through CI/CD pipelines. IAM policies follow least-privilege principles, and the system is modular, scalable, and fault-tolerant by design.

## Repository Structure:

![image.png](attachment:e4dc467b-a2bd-44e0-90b2-512a5fcd74b2:6e57323a-0a70-4357-a790-c6bc78423d1a.png)


## Architechture Diagram: 

![image.png](attachment:3e495e23-6f76-401d-a846-57c489773f26:image.png)

Key components:
-	VPC with public and private subnets across multiple Availability Zones (AZ)
-	Application Load Balancer (ALB) in public subnets
-	ECS Fargate service running tasks in private subnets
-	NAT Gateway for outbound internet access from private subnets
-	ACM certificate for HTTPS
-	Route 53 + Cloudflare for DNS
-	S3 + DynamoDB remote Terraform state backend
-	GitHub Actions for CI/CD using OIDC

Key Features:
- VPC, subnets, route tables
- Security groups
- Application Load Balancer and listeners
- ECS cluster, task definition and service
- IAM roles and policies
- ECR repository
- ACM certificate

## URL: https://tm.mwaqar.co.uk

![image.png](attachment:a7c9bb72-da51-4ae3-979c-bc90f6dddb5c:image.png)

## Reproduction Steps: 

### Prerequisites

- AWS account
- Terraform
- Docker
- GitHub repository
- Domain managed via Route 53 and/or Cloudflare

### Step 1: Local Setup:
```bash
yarn install
yarn build
yarn global add serve
serve -s build

#yarn start
http://localhost:3000/workspaces/default/dashboard

## or
yarn global add serve
serve -s build
```
- Exposed a simple route like /health returning {"status": "ok"}

![image.png](attachment:60661c8a-1bd5-4eb6-8386-ede18c3caff0:image.png)

### Step 2: Containerisation

- Created Dockerfile for the threat composer app. original image was 2.88GB so used multi-stage to make it smaller. Final image was reduced to 332MB. 

![image.png](attachment:ecdf9936-5de5-4a9c-b704-de7de5d3fdc8:image.png)

Dockerfile Breakdown: 

- Stage 1 - Build Stage
1. **FROM node:22-alpine AS builder** : indicates that it is a node.js and a smaller Alpine image Linux base. 
2. **WORKDIR /app** : everything else happens in /app. 
3. **COPY package.json yarn.lock /** and **RUN yarn install** : install dependencies using just the manifest files. (good for caching).
4. **COPY . .** : put the actual source code into the image
5. **RUN yarn build** : builds the app.

- Stage 2: Prod Stage
1. **RUN addgroup -S appgroup && adduser -S -G appgroup appuser**: Creates a non-root user for security
2. **RUN global add serve**: installs the serve package to serve the static build
3. **COPY - - from =builder /app/build ./build** : copies the build output
4. **RUN chown -R appuser:appgroup /app** : gives permission for non-root user to read files
5. **EXPOSE 3000** : shows that this container listens on port 3000. 
6. **USER appuser** : run global add serve as non-root user 
7. **CMD ["serve", "-s", "build", "-l", "3000"]** : starts the server when the container runs.

- Build the image : “docker build -t threatcomp . “
![image.png](attachment:d7dd0bfa-70c5-49b9-bdfe-524fefe980b9:image.png)

- Run command: “ docker run -p 3000:3000 threatcomp “

- On web browser open: [http://localhost:](http://localhost:3000)3000 and the app will load up: 

![image.png](attachment:8e88f40f-3af2-454a-8c09-65ebf60e8088:image.png)

- Run command “curl [http://localhost](http://localhost):80/health” and it should display this html message on terminal: 

![image.png](attachment:d8c8056e-6ea8-45a6-bede-dba1dfba037c:image.png)

- Click on the html link in the terminal and it should redirect to the app web UI. 

### Step 3: Image Registery (ECR)

Docker image has been pushed to AWS ECR. 

![image.png](attachment:302047e9-9184-4170-9233-e9cbd4ad4452:image.png)

- The main parts of the infrastructure were first created manually using the AWS console in order to understand how the services fit together.

- Created:
  - ECS Cluster (fargate).
  - Task definitions using the ECR Image.
  - Application Load Balancer.
  - Security Groups.
  - DNS Records.
  - ACM Certificate for HTTPS.

Once the application was reachable via HTTPS, all manual resources were deleted.

### Step 5: IaC (Terraform)

Created the the setup using modular Terraform.

- Iniitialised Terraform in the directory:
```bash
terraform init
```

- Iteretively planned and applied infrastructure while building modules:
``` bash
terraform plan
terraform apply
```

- Destroyed infrastructure at the end:
``` bash
terraform destroy
```

### Step 6: CI/CD Automation
Implemented Github Actions for the workflows.

### Build and Push 
![alt text](image.png)

### Terraform Deploy
![image.png](attachment:9d625e85-3844-41b1-908b-b447939233de:image.png)

### Health Check 
![image.png](attachment:0b413308-3225-4ecd-9395-c44dc19716e2:image.png)


The end result should be: 

![image.png](attachment:a7c9bb72-da51-4ae3-979c-bc90f6dddb5c:image.png)


## Future Improvements:
- Blue/Green deployment
- Auto-scaling policies
- CloudWatch monitoring and alarms
- AWS WAF integration
- Secrets Manager for application secrets
