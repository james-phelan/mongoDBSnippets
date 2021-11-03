# CA and IA certificate creation
perl -p -i -e "s|FQDNHOSTNAME|`hostname -f`|g" /certs/ca.cnf
openssl genrsa -out /certs/ca.key 4096
openssl req -new -x509 -days 1826 -key /certs/ca.key -out /certs/ca.crt -config /certs/ca.cnf
openssl genrsa -out /certs/ia.key 4096
openssl req -new -key /certs/ia.key -out /certs/ia.csr -config /certs/ia.cnf
openssl x509 -sha256 -req -days 730 -in /certs/ia.csr -CA /certs/ca.crt -CAkey /certs/ca.key -set_serial 01 -out /certs/ia.crt -extfile /certs/ca.cnf -extensions v3_ca
cat /certs/ca.crt /certs/ia.crt  > /certs/ca.pem

# Server certificate creation
perl -p -i -e "s|FQDNHOSTNAME|`hostname -f`|g" /certs/server.cnf
perl -p -i -e "s|IPADDRESS|`hostname -i`|g" /certs/server.cnf
openssl genrsa -out /certs/server.key 4096
openssl req -new -key /certs/server.key -out /certs/server.csr -config /certs/server.cnf
openssl x509 -sha256 -req -days 365 -in /certs/server.csr -CA /certs/ia.crt -CAkey /certs/ia.key -CAcreateserial -out /certs/server.crt -extfile /certs/server.cnf -extensions v3_req
cat /certs/server.crt /certs/server.key > /certs/server.pem

# Client certificate creation
perl -p -i -e "s|FQDNHOSTNAME|`hostname -f`|g" /certs/client.cnf
openssl genrsa -out /certs/client.key 4096
openssl req -new -key /certs/client.key -out /certs/client.csr -config /certs/client.cnf
openssl x509 -sha256 -req -days 365 -in /certs/client.csr -CA /certs/ia.crt -CAkey /certs/ia.key -CAcreateserial -out /certs/client.crt -extfile /certs/client.cnf -extensions v3_req
cat /certs/client.crt /certs/client.key > /certs/client.pem

# Create directories and set permissions
chown -R mongodb:mongodb /certs
chmod 400 /certs/*
mkdir -p /data/db
chown mongodb:mongodb /var/log/mongodb
chown mongodb:mongodb /etc/mongod.conf
chown mongodb:mongodb /data/db

su mongodb -c 'mongod --tlsMode requireTLS --tlsCertificateKeyFile /certs/server.pem  --tlsCAFile /certs/ca.pem  --dbpath /data/db --logpath /var/log/mongodb/mongod.log --fork'  -s /bin/sh -m
perl -p -i -e "s|CHANGEME|`openssl x509 -in /certs/client.pem -inform PEM -subject -nameopt RFC2253 | grep subject | awk 'BEGIN{FS="subject="}{print $2}'`|g" /app/createDBUser.js
mongo --quiet --tls --tlsCertificateKeyFile /certs/client.pem --tlsCAFile /certs/ca.pem --host 127.0.0.1 /app/createDBUser.js
