#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
docker run --restart always -e LB_INTERNAL=${lb_internal} -p 80:80 -d ibbuu/frontend_app:latest 