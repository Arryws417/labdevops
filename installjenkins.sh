#! /bin/bash

# install java
sudo yum install java-1.8.0-openjdk.x86_64 -y

# install and download jenkins
yum update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y

# start jenkins
systemctl start jenkins

# Enable jenkin with systemctl
systemctl Enable jenkins

# install git SCM
yum install git -y

# make sure jenkins Up/on when server reboot
chkconfig jenkins on
