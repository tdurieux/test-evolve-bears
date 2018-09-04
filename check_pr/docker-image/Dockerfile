FROM maven:3.3.9-jdk-8

LABEL Description="Bears checkbranch docker image" Vendor="Spirals" Version="0.0.0"

RUN mkdir -p /var/app/pr/

COPY . /var/app/

RUN echo "Europe/Paris" > /etc/timezone && chmod +x /var/app/*.sh
RUN apt-get update
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install nodejs
RUN npm install -g ajv-cli

ENV M2_HOME=$MAVEN_HOME

WORKDIR /var/app/
ENTRYPOINT /var/app/check_branches.sh