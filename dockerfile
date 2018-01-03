FROM jenkins/jnlp-slave:3.14-1
MAINTAINER michael.dasilva@investorsgroup.com

USER root

# components for shell access
RUN apt-get update && apt-get install -y openssh-client openssh-server sudo vim
# bug with openssh-server
RUN mkdir /run/sshd

# add jenkins to sudo group and remove password prompt
RUN usermod -aG sudo -s /bin/bash jenkins && \
 sed -i 's/^\(%sudo[[:blank:]]ALL=(ALL:ALL)[[:blank:]]\)ALL/\1NOPASSWD:ALL/' /etc/sudoers

# allow root ssh logins
RUN sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# set passwords
RUN ["/bin/bash", "-c", "echo -e 'jenkins\njenkins' | passwd jenkins --"]
RUN ["/bin/bash", "-c", "echo -e 'root\nroot' | passwd root --"]

# setup script for remote shell access 
COPY ssh-keys/* /home/jenkins/.ssh/
RUN chown jenkins:jenkins /home/jenkins/.ssh/*
# script starts sshd, creates a reverse ssh tunnel out to a gateway host, then sleeps for a fixed time
# to be optionally called as a build step
COPY start-shell-access.sh /usr/local/bin/

USER jenkins

