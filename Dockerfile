# Use the latest version of ubuntu
FROM phusion/baseimage:latest
MAINTAINER Justin Ellison <justin@techadvise.com>

# Set Debian apt-get to be noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Install the required packages
RUN apt-get update && \
    apt-get install -y sudo && \
		curl -sL -o /build/setup.sh https://deb.nodesource.com/setup_10.x && \
		/build/setup.sh && \
		apt-get -q update && \
		apt-get install -qy build-essential ibavahi-compat-libdnssd-dev \
		  libasound2-dev git nodejs

# Add the build location and all the required files
ADD . /build

# Setup the node user idea that airsonos will run under
RUN useradd -m node

# Switch to the node user for further processing
USER node

# Setup the npm-global
RUN mkdir ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
		echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile && \
    source ~/.profile && \
		mkdir -p /etc/my_init.d         # create phusion startup dir

# Install required node packages
RUN npm install --global babel-cli && \
    cd /var/tmp/

# Obtain airsonos, compile and install
RUN git clone https://github.com/adamcoulthard/airsonos && \
    cd airsonos && \
		npm run-script prepare && \
		npm install -g --unsafe-perm

#RUN /build/install.sh
# && \
#	/build/cleanup.sh

# Removed for the time being to allow some testing to happen
# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

EXPOSE 5000 5001 5002 5003 5004 5005 5006 5006 5007 5008 5009 5010 5011 5012 5013 5014 5015

ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
