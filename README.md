1. Vagrant Cluster

    I have written Vagrantfile for describing local infrastructure
    Vagrantfile location is:
        -   ./Vagrantfile
    
    Use command "vagrant up" to run and setup 3 VM's (host01, host02, host03).
        host03 - is a master. Vagrant installs Ansible on that server. Also, runs docker swarm cluster.
        host01, host02 - are slave servers. Those VM's join to the Docker Swarm using Token which generates on a host03.

2. Ansible. 

    We are using Ansible for:
        1) Installation and configuration docker on all hosts.
        2) Setups NFS and connect it to all hosts. 

    We are using ansible roles to configure hosts. All roles are described in "./ansible" folder.  

3. Terraform

    I have used Terraform to UP little infrastructure in the AWS. I have written a config.tf file, where I describe infrastructure which we need to up. By the security reason, I have added files with AWS_CREDENTIALS and SSH_KEYS to the git ignore file.

    Terraform configuration file is located in: 
        -    terraform/config.tf
    
4. Docker
    
    We are using docker-swarm for running Docker containers in a cluster.
    For initializing docker cluster we are using ansible roles:


        - docker-nodes - to install docker in all hosts
        - docker-master - to initialize docker-master host. 
        - docker-slave - to connect other nodes to the swarm cluster.
    

    Also, I have marked all hosts as a worker, by using the following commands:

        docker node update --label-add type=worker host01
        docker node update --label-add type=worker host02
        docker node update --label-add type=worker host03
    
    
5. Jenkins + Sonarqube + Artifactory

    We have runs the job which builds maven project and runs Sonarqube analysis.
    Sonarqube is connected to the Jenkins by Sonarqube plugin for a Jenkins.

    Url to the maven project: https://github.com/MykhayloLohvynenko/java-maven-junit-helloworld

    Jenkins requires a directory which will be available from all hosts. So I have created a new directory on an NFS store. 
    
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
    
    We are using docker registry to save docker image which we have built via the Jenkins and run this image on docker swarm.
    For up dokcer registry I am using next command:

        docker service create --name registry \
        -p 5000:5000 \
        --constraint 'node.hostname == host03' \
        registry:2

    I have uses already existed Artifactory server which I have configured for mine current project.

6. ELK
    
    For elasticsearch to not give Out of Memory errors, we need set vm.max_map_count of the kernel of VMs to atleast 262144. To do this, run the following commands:
    
        docker-machine ssh manager sudo sysctl -w vm.max_map_count=262144
        docker-machine ssh agent1 sudo sysctl -w vm.max_map_count=262144
        docker-machine ssh agent2 sudo sysctl -w vm.max_map_count=262144


    We will define the entire stack for logging in the docker-stack.yml file. This will contain the information about different services including the deploy stratergies. This file will be in the docker-compose v3 format. We can then deploy it with one command.
    
    docker-stack.yml file location is ./ELK/docker-stack.yml

    For elasticsearch to not give Out of Memory errors, we need set vm.max_map_count of the kernel of VMs to atleast 262144. To do this, run the following commands:

        docker-machine ssh manager sudo sysctl -w vm.max_map_count=262144
        docker-machine ssh agent1 sudo sysctl -w vm.max_map_count=262144
        docker-machine ssh agent2 sudo sysctl -w vm.max_map_count=262144

    We also need to setup a custom configuration file for logstash to define its pipeline. 
    
    The configuration file logstash.conf location is:
        -   ./ELK/logstash/logstash.conf

    The config file contains three sections. The input section defines where logstash is listening for log data. In this case,logstash will listen at port 5000 where log will be coming in json format and using UDP protocol. The filter section can do some processing with the log data. Here, we will drop all the logs coming from logstash image, as those are duplicates. The output section defines where logstash is feeding the data to. Here, we will send it to elasticsearch service at port 9200.

    To deploy this stack run the following command: 
        
        docker stack deploy -c docker-stack.yml elk
    
    This will start the services in the stack named elk. The first time takes more time as the nodes have to download the images. To see the services in the stack, you can use the command "docker stack services elk", the output of the command will look like this:
        
        ID            NAME                   MODE        REPLICAS  IMAGE
        07h9zishcka5  logging_logspout       global      3/3       bekt/logspout-logstash:latest
        7upb3emlhsft  logging_kibana         replicated  1/1       docker.elastic.co/kibana/kibana:5.3.2
        puxx0x4txa50  logging_logstash       replicated  1/1       docker.elastic.co/logstash/logstash:5.3.2
        wyjkad4do7oi  logging_elasticsearch  replicated  1/1       docker.elastic.co/elasticsearch/elasticsearch:5.3.2
    
    To see the running containers in the stack with the command "docker stack ps elk". Its output will look like this:

        ID            NAME                                        IMAGE                                                NODE     DESIRED STATE  CURRENT STATE               ERROR                      PORTS
        jqr1m6ts21p3  logging_logspout.pt27y28y0t5zzph3oi72tmy58  bekt/logspout-logstash:latest                        agent2   Running        Running about a minute ago
        4zwvtt3momu3  logging_logspout.9m6jopba7lr0o40hw9nwe7zfb  bekt/logspout-logstash:latest                        agent1   Running        Running about a minute ago
        mgpsi68gcvd9  logging_logspout.ub1sl7d5fy9dbnlx8um67a03t  bekt/logspout-logstash:latest                        manager  Running        Running about a minute ago
        unz9qrfit8li  logging_logstash.1                          logstash:alpine                                      agent1   Running        Running 2 minutes ago
        jjin64lsw2dr  logging_kibana.1                            docker.elastic.co/kibana/kibana:5.3.0                agent2   Running        Running 2 minutes ago
        orzfd05rzq8e  logging_elasticsearch.1                     docker.elastic.co/elasticsearch/elasticsearch:5.3.0  agent1   Running        Running 3 minutes ago
    
7. Zabbix     
    
   I have installed and configured Zabbix server on server host04. 
   
        URL to zabbix server: http://192.168.11.14/zabbix
    
   For installation Zabbix server I have to use the following guide:
    
    https://serveradmin.ru/ustanovka-i-nastroyka-zabbix-3-4-na-centos-7/

   Zabbix agents were installed by using docker container zabbix-agent. 
   Run container:

    docker run --name zabbix-agent -e ZBX_HOSTNAME="$(hostname)" -e ZBX_SERVER_HOST="192.168.11.14" -p 10050:10050 --privileged -d zabbix/zabbix-agent:alpine-3.4-latest

8. cadvisor monitoring

    We will define the entire stack for monitoring in the docker-stack.yml file. This will contain the information about different services including the deploy stratergies. This file will be in the docker-compose v3 format. We can then deploy it with one command.
        
    docker-stack.yml file location is:
        -   ./ELK/docker-stack.yml

    To deploy this stack run the following command:
    
        docker stack deploy -c docker-stack.yml monitor

    This will start the services in the stack which is named monitor. This might take some time the first time as the nodes have to download the images. Also, you need to create the database named cadvisor in InfluxDB to store the metrics.

        docker exec `docker ps | grep -i influx | awk '{print $1}'` influx -execute 'CREATE DATABASE cadvisor'

    This command might fail saying that the influx container doesn’t exist. This is beacuse the container is not yet ready. Wait for some time and run it again. We are able to run the commands in the influx service beacuse it is running in manager and we are using its docker engine. To find the ID of InfluxDB container, you can use the command docker ps | grep -i influx | awk '{print $1}' and we are executing the command influx -execute 'CREATE DATABASE cadvisor' to create the new database names cadvisor.

    Configuring grafana
    
    Once the services are deployed, you can open up grafana with the IP of any node in the swarm. We will open the IP of manager with the following command.

    - Grafana URL: http://`docker-machine ip manager`

    By default, use the username admin and password admin to login to grafana. The first thing to do in grafana is to add InfluxDB as the datasource. In the home page, there must be a Create your first data source link, click that. If the link is not visible, you can select Data Sources from menu and choosing Add data source from there. This will give you the form to add a new Data Source.

    You can give any name for the source. Check the default box, so that you won’t have to mention the data source everywhere. Choose the type as InfluxDB. Now, the URL is http://influx:8086 and Access is proxy. This will point to the port listened by the InfluxDb container. Finally give the Database as cadvisor and click the Save and Test button. This should give the message Data source is working.

    I have added the file dashboard.json, that can be imported to Grafana.  This will provide a dashboard that monitors the systems and the containers running in the swarm. We will import the dashboard now and talk about it in the next section. From the menu, hover over Dashboards and select Import Option. Click the Upload .json file button and choose the dashboard.json file. Select the data source and click the Import button to import this dashboard.
    
    dashboard.json location: 
        -   ./cadvisor/Grafana/dashboard.json





