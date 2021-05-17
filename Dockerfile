FROM ubuntu:18.04

LABEL maintainer="Vuong Ngo <vuong@mieli.de>"

USER root

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git curl gnupg2 gnupg1 gnupg2 && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 
    apt-get install -qy openjdk-11-jdk && \
# Cleanup old packages
    apt-get -qy autoremove && \
# Add user jenkins to the image
    adduser --quiet jenkins && \
# Set password for the jenkins user.
    echo "jenkins:jenkins" | chpasswd && \
    mkdir /home/jenkins/.m2

RUN chown -R jenkins:jenkins /home/jenkins 

# add yarn repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# install yarn
RUN apt-get install yarn -y

# install docker
RUN apt-get install -qy docker.io
RUN usermod -aG docker jenkins

# install docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose


# Standard SSH port
EXPOSE 22

USER jenkins

CMD ["/usr/sbin/sshd", "-D"]