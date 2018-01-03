FROM mdasilva/jenkins-jnlp-slave:latest
#FROM jenkins/jnlp-slave:3.14-1
MAINTAINER michael.dasilva@investorsgroup.com

USER root
RUN mkdir pkgs

# oracle java package
# RUN wget -q --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz"
COPY jdk-8u151-linux-x64.tar.gz pkgs/

# install oracle java
RUN mkdir /opt/java && \
 tar zxvf pkgs/jdk-8u151-linux-x64.tar.gz -C /opt/java && \
 update-alternatives --install /usr/bin/java java /opt/java/jdk1.8.*/bin/java 2000 && \
 update-alternatives --auto java

# install build tools
RUN apt-get update && \
 apt-get install -y maven gradle ant

USER jenkins
