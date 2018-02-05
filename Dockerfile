# DOCKER-VERSION 1.8.1
# METEOR-VERSION 1.2.1
FROM ubuntu:trusty

# Create user meteor who will run all entrypoint instructions
RUN useradd meteor -G staff -m -s /bin/bash
WORKDIR /home/meteor

# Install git, curl
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list \ && apt-get update && \
   apt-get  --force-yes install -y fontconfig libfontconfig1 git curl build-essential && \
   (curl https://deb.nodesource.com/setup_8.x | bash) && \
   apt-get install --force-yes -y nodejs jq s3cmd wget && \
   apt-get clean && \
   rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#RUN cd /usr/local/share && wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2 && tar xjf phantomjs-1.9.7-linux-x86_64.tar.bz2 && ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/share/phantomjs && ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/bin/phantomjs
RUN npm install -g semver

# Install entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Add known_hosts file
COPY known_hosts .ssh/known_hosts

RUN chown -R meteor:meteor .ssh /usr/bin/entrypoint.sh

# Allow node to listen to port 80 even when run by non-root user meteor
# https://github.com/moby/moby/issues/5650
# RUN setcap 'cap_net_bind_service=+ep' /usr/bin/node

EXPOSE 3000

# Execute entrypoint as user meteor
ENTRYPOINT ["su", "-c", "/usr/bin/entrypoint.sh", "meteor"]
CMD []
