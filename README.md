Docker Swarm Deployment for Yii2 PHP App

Introduction

This project demonstrates deploying a Yii2 PHP application using Docker Swarm on an EC2 instance. It includes infrastructure automation with Ansible and a CI/CD pipeline using GitHub Actions.

Docker Swarm Deployment
 I’ve created a basic Dockerfile for a Yii2 PHP application and a Docker Compose file to define the service. The app is deployed as a Docker Swarm service on an EC2 instance.

Steps:
Log into the EC2 instance and initialize Docker Swarm.

Run the following command to deploy the stack:

docker stack deploy -c docker-compose.yml yii2
This launches the Yii2 app container on port 8080.

Dockerfile
================

FROM php:7.4-apache

RUN docker-php-ext-install pdo pdo_mysql

COPY . /var/www/html/



Docker Compose File
============================
version: "3.8"

services:
  yii2-app:
    image: ashutosh1999/yii2-app:latest
    ports:
      - "8080:80"
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure


Running Service
To verify the service is running, use the following command:

docker service ls


NGINX Host-Based Proxy
I configured NGINX directly on the EC2 host. The NGINX reverse proxy listens on port 80 and forwards requests to port 8080, where the Yii2 container runs.

NGINX Configuration File
=====================
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://18.212.71.237:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}


Deploying NGINX
I copied the NGINX config file to /etc/nginx/sites-available/default, and then restarted the NGINX service.

To verify NGINX is running, use the following:

open http://18.212.71.237/ in your browser.

 Infrastructure Automation with Ansible
I used Ansible to automate the EC2 setup. The playbook installs Docker, NGINX, Git, starts Docker, initializes Swarm, and deploys the NGINX config.

Steps:
Run the following command to execute the playbook:


ansible-playbook -i hosts ansible/provision.yml
The playbook automates:

Installing required packages.

Starting Docker and NGINX.

Initializing Docker Swarm.

Deploying the NGINX config.

Example Playbook Content (ansible/provision.yml)
---
- hosts: web
  become: true
  tasks:
    - name: Install required packages
      apt:
        name:
          - docker.io
          - nginx
          - git
        state: present
        update_cache: yes

    - name: Start Docker service
      service:
        name: docker
        state: started
        enabled: yes

    - name: Initialize Docker Swarm
      shell: docker swarm init || true

    - name: Copy NGINX config to the server
      copy:
        src: ../nginx/default.conf
        dest: /etc/nginx/sites-available/default

    - name: Test NGINX config
      command: nginx -t

    - name: Restart NGINX service
      service:
        name: nginx
        state: restarted

Running Ansible
Once the playbook is executed, Docker and NGINX will be set up, and the Yii2 app will be ready for deployment.

Verifying Docker and NGINX are Up
To confirm Docker and NGINX are running:

docker ps  
sudo systemctl status nginx  

CI/CD with GitHub Actions

In last, I implemented a CI/CD pipeline using GitHub Actions. Whenever I push code to the main branch, it automatically:

Builds the Docker image.

Pushes the image to Docker Hub.

SSHs into the EC2 server.

Updates the running Docker Swarm service with the new image.

This workflow enables continuous deployment without manual intervention.

GitHub Actions Workflow File (.github/workflows/deploy.yml)
======================================
name: Deploy Yii2 App

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v2

      - name: Build Docker Image
        run: docker build -t ashutosh1999/yii2-app:latest ./src

      - name: Login to DockerHub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Push Docker Image
        run: docker push ashutosh1999/yii2-app:latest

      - name: SSH and Update Docker Swarm
        uses: appleboy/ssh-action@v0.1.6
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.PRIVATE_KEY }}
          script: |
            docker pull ashutosh1999/yii2-app:latest
            docker service update --image ashutosh1999/yii2-app:latest yii2_app
Triggering the Workflow
To trigger the workflow, simply push code to the main branch in your repository. The GitHub Actions pipeline will:

Build and push the Docker image.

SSH into the EC2 instance and update the running Docker service.

Verifying the Container After Deployment
After deployment, open your browser and visit http://<your-ec2-public-ip>/ to verify that the updated Yii2 app is running.

Assumptions
NGINX is configured directly on the EC2 host, not within a container.

DockerHub credentials are stored in GitHub Secrets for secure access.

Docker Swarm is used for orchestration, and the service is deployed using the docker stack deploy command.

Ansible is used to automate the setup of the EC2 instance.

GitHub Actions automates the CI/CD pipeline for building and deploying the Docker image.

Conclusion
With these assignments, I’ve automated the entire setup process using Docker, NGINX, Ansible, and GitHub Actions. The result is a fully automated deployment pipeline for the Yii2 PHP application, which can be easily updated and managed.

