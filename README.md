# What is this?

This is completely self-contained and fully automated I/CaaC demo in AWS.

This repository contains a number of terraform modules that will:

1. Create a pretty standard 3 tier network in AWS (VPC with backend/frontend/dmz subnets, everything duplicated in two AZs)
1. Create EKS cluster and ASG workers
1. Deploy tiller and then nginx ingress to the cluster
1. Create ECR repository for the app
1. Deploy Jenkins using a helm chart

Jenkins will be automatically configured to track https://github.com/llibicpep as a GitHub org.

Repositories with the name matching `jenkins-terraform-kubernetes-demo*` and having a `Jenkinsfile` will be automatically served by this instance of Jenkins.

There is a demo app repository https://github.com/llibicpep/jenkins-terraform-kubernetes-demo-app already setup. This repository contains a hello world Spring Boot app, a Dockerfile to build an image with it, a helm chart to deploy it to kubernetes, and also a Jenkinsfile to orchestrate the pipeline for all of it. Only master branch get deployed, rest of the branches and PRs just run through tests.

# Assumptions

This is not a production ready solution. The sole purpose of this is to demonstrate some of capabilities in terraform+jenkins+kubernetes+helm combination. There would be a number of TODOs to make this production grade:

1. Some VPN service required to dial into the private network
1. Currently only 1 of 3 network tiers is used, kubernetes ingress controller LB needs to be moved to DMZ network
1. Single repo is not a best choise, better to split it up to tiers such as: network, kubernetes cluster, k8s addons, jenkins and apps. Each tier would be managed separately.
1. IAM stuff needs much more thoroughly revisited, it has too widely open permissions right now.
1. Cluster needs auto scaler
1. Need a route53 DNZ zone and certificate manager to fully support ssl
1. Need Nexus or Artifactory to storing application artifacts
1. Passing credentials around in terraform is not safe, either Vault or AWS Secrets Manager needed
1. Jenkinsfile in the application repo would be redundant on a scale - some Groovy Shared library required to abstract out certain things and make developers life easier

# Prerequisites

1. AWS account
1. GitHub account
1. Docker

# How to use

1. Give yourself an access into an AWS account using AWS CLI
1. Create GitHub token for Jenkins to use
1. For portability there is a `Dockerfile` in this repository that has everything you need to make this demo work (for Windows users - figure out how to mount AWS credentials file on your own):
    ```
    docker build -t jenkins-terraform-kubernetes-demo-app .
    docker run --rm -v $(cd && pwd)/.aws:/root/.aws -v $(pwd):/dir -w /dir -it --entrypoint "bash" jenkins-terraform-kubernetes-demo-app
    ```
1. Check that you have AWS access within the container:
    ```
    aws sts get-caller-identity
    ```
1. Apply terraform:
    ```
    terraform init
    terraform apply
    ```
1. Terraform will ask you about your IP CIDR to whitelist for the cluster and ingress controller (since we don't have VPN) and your GitHub token
1. Go get some tea or coffe or whatever. It'll take a while. Note it'll create some EC2+EKS+ECR+whatnot - not everything is free tier eligible and going to cost some little money.
1. When terraform is done - you'll see:
    * `cluster_dns` - API endpoint for your EKS cluster
    * `ecr_url` - the ECR url
    * `ingress_lb` - the LB dns that you got for your Ingress controller (it'll route both Jenkins and the app)
1. Grab Jenkins admin password from AWS Secrets Manager - for obvious security reasons it doesn't print in stdout
1. Open `http://<ingress_lb>` and use admin user with that pass
1. You'll see `llibicpep` forler, go inside and click `Scan Organization Now`
1. This will scan repos, branches and PRs and produce pipelines for the org
1. Go in the master pipeline for the demo app, and build it
1. When it finishes - the app will be available under `http://<ingress_lb>/app/greeting`
1. When you done, you can just destroy everything using:
    ```
    terraform destroy
    ```
1. Note that since images in ECR were not managed by terraform and I'm too lazy put together a workaround for it - previous step would fail till you manually clean up all images under given ECR repository.