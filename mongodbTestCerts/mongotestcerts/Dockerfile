FROM debian:buster
WORKDIR /app
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y apt-utils wget gnupg gnupg2 curl

RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
RUN echo "deb http://repo.mongodb.com/apt/debian buster/mongodb-enterprise/5.0 main" | tee /etc/apt/sources.list.d/mongodb-enterprise.list
RUN apt-get update
RUN apt -y install software-properties-common build-essential libnss3-dev zlib1g-dev libgdbm-dev libncurses5-dev libssl-dev libffi-dev libreadline-dev libsqlite3-dev libbz2-dev

RUN apt-get install -y mongodb-enterprise
RUN apt-get install -y mongodb-enterprise-shell 
RUN apt-get install -y mongodb-enterprise-tools

COPY mongod/mongod.conf /etc/mongod.conf
COPY mongod/mongodSetup.sh /app/mongodSetup.sh
COPY mongod/createDBUser.js  /app/createDBUser.js 
COPY certs/ /certs/

RUN chmod +x /app/mongodSetup.sh
RUN /app/mongodSetup.sh
RUN chown mongodb:mongodb /certs

EXPOSE 5000
CMD ["sh", "-c", "su mongodb -c 'mongod -f /etc/mongod.conf' -s /bin/sh -m"]