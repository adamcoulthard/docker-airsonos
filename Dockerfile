# Use the latest version of ubuntu
FROM phusion/baseimage:latest
MAINTAINER Justin Ellison <justin@techadvise.com>

# Set Debian apt-get to be noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Add the build location and all the required files
ADD . /build

# Install the required packages
RUN apt-get update && \
    apt-get install -y sudo && \
		curl -sL -o /build/setup.sh https://deb.nodesource.com/setup_10.x && \
    chmod 700 /build/setup.sh && \
		/build/setup.sh && \
    apt-get -q update && \
		apt-get install -qy build-essential libavahi-compat-libdnssd-dev \
		  libasound2-dev git nodejs bash

# Setup the node user idea that airsonos will run under
RUN useradd -m node && \
    adduser node sudo

# Switch to the node user for further processing
USER node

# Setup the npm-global
RUN mkdir ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
		echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile && \
		mkdir -p /etc/my_init.d         # create phusion startup dir

# Setup the PATH environment variable for the docker execution
ENV PATH=/home/node/.npm-global/bin:$PATH

# Install required node packages
RUN npm install --global babel-cli

# Obtain airsonos, compile and install
RUN cd /home/node && \
    git clone https://github.com/adamcoulthard/airsonos && \
    cd airsonos && \
		echo $PATH && \
		ls /home/node/.npm-global/bin && \
 		npm run-script prepare && \
		npm install -g --unsafe-perm

# Switch back to the root user for the final setup
USER root

# Clean up some of the files that we have been using
RUN apt-get -y purge build-essential && \
    apt-get -y autoremove && \
    apt-get clean

# Removed for the time being to allow some testing to happen
# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

EXPOSE 5000 5001 5002 5003 5004 5005 5006 5006 5007 5008 5009 5010 5011 5012 5013 5014 5015

ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
