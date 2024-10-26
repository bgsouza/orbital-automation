
# Deploying a Full-Stack Application Using Terraform and GitLab CI/CD


## 1. Working with Terraform Workspaces

Terraform workspaces allow you to manage multiple environments (like `dev` and `prod`) using the same configuration.

### Create Workspaces

```bash
# Initialize Terraform
terraform init

# Create and switch to the dev workspace
terraform workspace new dev

# Create and switch to the prod workspace
terraform workspace new prod
```

### Switch Between Workspaces

```bash
# Switch to the dev workspace
terraform workspace select dev

# Switch to the prod workspace
terraform workspace select prod
```

## 2. Configuring AWS CLI and Credentials

Before running Terraform or GitLab CI/CD, ensure that the AWS CLI is installed and configured.

### Install AWS CLI

```bash
# On macOS
brew install awscli

# On Ubuntu
sudo apt-get update
sudo apt-get install awscli
```

### Configure AWS CLI

```bash
aws configure
# Provide the AWS Access Key ID, Secret Access Key, region, and output format when prompted.
```

## 3. Running Terraform Commands

Once workspaces are set up and AWS CLI is configured, run Terraform commands to manage the infrastructure.

### Plan

```bash
terraform plan -var-file=vars/dev.tfvars
```

### Apply

```bash
terraform apply -var-file=vars/dev.tfvars
```

### Destroy

```bash
terraform destroy -var-file=vars/dev.tfvars
```

## 4. Setting Up GitLab CI/CD

### 4.1 Back-End GitLab CI/CD Configuration

Create a `.gitlab-ci.yml` file for the back-end:

```yaml
image: php:7.4

stages:
  - build
  - deploy

cache:
  paths:
    - vendor/
    - node_modules/

build:
  stage: build
  script:
    - apt-get update
    - apt-get install -y git unzip libpng-dev libjpeg-dev libfreetype6-dev libgd-dev libzip-dev libbz2-dev
    - docker-php-ext-install gd pcntl zip bz2
    - curl -sS https://getcomposer.org/installer | php
    - php composer.phar install --ignore-platform-reqs --no-interaction --prefer-dist --optimize-autoloader

deploy:
  stage: deploy
  image:
    name: amazon/aws-cli:latest
    entrypoint: 
      - '/usr/bin/env'
  script:
    # Usar as credenciais específicas do back-end
    - export AWS_ACCESS_KEY_ID=$BACK_AWS_ACCESS_KEY_ID
    - export AWS_SECRET_ACCESS_KEY=$BACK_AWS_SECRET_ACCESS_KEY
    - export AWS_REGION=$BACK_AWS_REGION

    # install zip
    - yum install -y zip

    # Zipar e fazer o upload do pacote de deploy para o S3
    - zip -r backend-app.zip .
    - aws s3 cp backend-app.zip s3://$BACK_S3
 
    # Atualizar o Elastic Beanstalk
    - aws elasticbeanstalk update-environment --application-name $BACK_BEANSTALK_NAME --environment-name $BACK_BEANSTALK_NAME_ENV --version-label v1
  only:
    - develop
```

### 4.2 Front-End GitLab CI/CD Configuration

Create a `.gitlab-ci.yml` file for the front-end:

```yaml
image: node:16

stages:
  - build
  - deploy

cache:
  paths:
    - node_modules/

build:
  stage: build
  script:
    - yarn install
    - yarn build
  artifacts:
    paths:
      - dist/

deploy:
  stage: deploy
  image:
    name: amazon/aws-cli:latest
    entrypoint: 
      - '/usr/bin/env'
  script:
    # Usar as credenciais específicas do front-end
    - export AWS_ACCESS_KEY_ID=$FRONT_AWS_ACCESS_KEY_ID
    - export AWS_SECRET_ACCESS_KEY=$FRONT_AWS_SECRET_ACCESS_KEY
    - export AWS_REGION=$FRONT_AWS_REGION
    - echo  "Verificar se há arquivos no diretório dist/"
    - ls -l dist/
    - echo "Testar as credenciais listando o bucket S3"
    - aws s3 ls s3://$FRONTEND_APP-bucket-prod

    # Deploy para o S3
    - aws s3 sync dist/ s3://$FRONTEND_APP-bucket-prod --delete

    # Invalidação de cache no CloudFront
    - aws cloudfront create-invalidation --distribution-id $FRONT_DISTRIBUTION_ID --paths "/*"
  only:
    - develop
```

## 5. Setting Up GitLab CI/CD Variables

To make the pipelines work, set the following variables in the GitLab repository's **CI/CD settings**.

### Back-End Variables

- `BACK_AWS_ACCESS_KEY_ID`: The AWS access key for the back-end deployment.
- `BACK_AWS_SECRET_ACCESS_KEY`: The AWS secret access key for the back-end deployment.
- `BACK_AWS_REGION`: The AWS region where resources are located (e.g., `us-east-1`).
- `BACK_S3`: The S3 bucket for storing the back-end deployment packages.
- `BACK_BEANSTALK_NAME`: The name of the Elastic Beanstalk application for the back-end.
- `BACK_BEANSTALK_NAME_ENV`: The environment name for the back-end Elastic Beanstalk.

### Front-End Variables

- `FRONT_AWS_ACCESS_KEY_ID`: The AWS access key for the front-end deployment.
- `FRONT_AWS_SECRET_ACCESS_KEY`: The AWS secret access key for the front-end deployment.
- `FRONT_AWS_REGION`: The AWS region for the front-end deployment (e.g., `us-east-1`).
- `FRONTEND_APP`: The name of the front-end application (used for S3 bucket naming).
- `FRONT_DISTRIBUTION_ID`: The CloudFront distribution ID for cache invalidation.

## 6. Creating Deploy Users on AWS

1. Go to the AWS IAM console.
2. Create users (e.g., `orbital-deploy-api` for the back-end and `orbital-deploy-front` for the front-end).
3. Attach the necessary policies for S3, CloudFront, and Elastic Beanstalk management.
4. Add the access keys to the GitLab CI/CD variables.

