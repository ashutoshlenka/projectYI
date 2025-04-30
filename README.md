# Yii2 Docker Swarm Deployment with Ansible and GitHub Actions

This project demonstrates a DevOps pipeline that deploys a Yii2 PHP application using Docker Swarm, NGINX (host-based reverse proxy), GitHub Actions (CI/CD), and Ansible on an AWS EC2 instance.

---

##  Live Application

> http://18.212.71.237/

---

##  Project Structure

. ├── src/ # Yii2 App (from GitHub) │ ├── Dockerfile # Container config ├── docker-compose.yml # Swarm definition ├── ansible/ │ └── provision.yml # Server provisioning playbook ├── nginx/ │ └── default.conf # NGINX host-based proxy config ├── .github/ │ └── workflows/ │ └── deploy.yml # GitHub Actions CI/CD workflow


---

##  Setup Instructions

### 1. Launch and Connect to AWS EC2
- Launch an Ubuntu EC2 instance.
- Open ports **22**, **80**, and **8080** in the EC2 security group.
- Login into the instance by EC2 Instance connect


2.  Provision Server with Ansible
Requirements:
Ansible installed locally and SSH access to EC2 instance

provision.yml:
-----------------
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

    - name: Start Docker
      service:
        name: docker
        state: started
        enabled: yes

    - name: Initialize Docker Swarm
      shell: docker swarm init || true

    - name: Copy NGINX config
      copy:
        src: ../nginx/default.conf
        dest: /etc/nginx/sites-available/default

    - name: Restart NGINX
      service:
        name: nginx
        state: restarted


Run the Command From your project root directory, run:

 ansible-playbook -i hosts ansible/provision.yml


What it does:

Installs Docker, Git, and NGINX

Initializes Docker Swarm

Configures host-level NGINX as reverse proxy

3.  Docker Setup
Dockerfile (inside src/):

Dockerfile
--------------
FROM php:7.4-apache
RUN docker-php-ext-install pdo pdo_mysql
COPY . /var/www/html/
WORKDIR /var/www/html/web


docker-compose.yml:
---------------------
version: "3.8"
services:
  yii2-app:
    image: yourdockerhubusername/yii2-app:latest
    ports:
      - "8080:80"
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure


5.  NGINX Config (on host)

nginx/default.conf:
--------------------

server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
Copy to EC2 at /etc/nginx/sites-available/default, 
then:

sudo nginx -t
sudo systemctl reload nginx


5.  CI/CD with GitHub Actions
.github/workflows/deploy.yml:
-----------------------------------

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
        run: docker build -t yourdockerhubusername/yii2-app:latest ./src

      - name: Login to DockerHub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Push Docker Image
        run: docker push yourdockerhubusername/yii2-app:latest

      - name: SSH and Update Docker Swarm
        uses: appleboy/ssh-action@v0.1.6
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.PRIVATE_KEY }}
          script: |
            docker pull yourdockerhubusername/yii2-app:latest
            docker service update --image yourdockerhubusername/yii2-app:latest yii2_app
Required GitHub Secrets:
DOCKER_USERNAME

DOCKER_PASSWORD

HOST (EC2 IP)

USERNAME (e.g., ubuntu)

PRIVATE_KEY (your SSH private key)


 
 How to Test Deployment
Push code to main branch.

GitHub Actions will:

Build and push Docker image

SSH into EC2

Pull and update Docker Swarm service

Visit the page:

  http://18.212.71.237/


 Assumptions

* NGINX is running on the EC2 host, not in a container.

* Docker Swarm is used for deploying a single-node service.

* Yii2 app runs from the /web directory.

* EC2 security group allows ports 22, 80, and 8080.

* Docker image is pushed to Docker Hub (yourdockerhubusername/yii2-app).


 Cleanup
To remove the Docker service:
 docker service rm yii2_app

To stop Docker Swarm (optional):
 docker swarm leave --force


 Author
Ashutosh – DevOps Assessment
