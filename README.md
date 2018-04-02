1. Vagrant Cluster
    Use command "vagrant up" to run and setup 3 VM's (host01, host02, host03).
        host03 - is a master. Vagrant installs Ansible on that server. Also, runs docker swarm cluster.
        host01, host02 - are slave servers. Those VM's join to the Docker Swarm using Token which generates on a host03.

2. Ansible. 
    We are using Ansible for:
        1) Installation and configuration docker on all hosts.
        2) Setups NFS and connect it to all hosts. 

3. Terraform
    I have used Terraform to UP little infrastructure in the AWS. I have written a config.tf file, where I describe infrastructure which we need.

4. Docker
    We are using Docker for:
        1) Running Jenkins
        2) Running Sonarqube 
    
    For run Jenkins & Sonarqube on a Docker Swarm, we should mark all hosts as a worker.
        docker node update --label-add type=worker host02
        docker node update --label-add type=worker host03
        docker node update --label-add type=worker host01

    Jenkins. Jenkins requires a directory which will be available from all hosts. So I have created a new directory on an NFS store. 
        mkdir -p /opt/docker/jenkins
        
    For run Jenkins I am using next command:
    
    docker service create --name jenkins-test \
        -p 8080:8080 \
        -p 50000:50000 \
        --constraint 'node.hostname == host03' \
        -e JENKINS_OPTS="--prefix=/jenkins" \
        --mount "type=bind,source=/opt/docker/jenkins,target=/var/jenkins_home" \
        --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
        --reserve-memory 300m \
        jenkins-docker-cli

    For run Sonarqube I am using next command:
        docker service create --name sonarqube \
        -p 9000:9000 \
        -p 9092:9092 \
        --constraint 'node.labels.type == worker' \
        sonarqube
    
    For up dokcer registry I am using next command:
    
        docker service create --name registry \
        -p 5000:5000 \
        --constraint 'node.hostname == host03' \
        registry:2

5. Jenkins + Sonarqube
    We have runs the job which builds maven project and runs Sonarqube analysis.
    Sonarqube is connected to the Jenkins by Sonarqube plugin for a Jenkins.

  Url to the maven project: https://github.com/MykhayloLohvynenko/java-maven-junit-helloworld




