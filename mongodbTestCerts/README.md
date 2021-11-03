# Test certificates for MongoDB

This demo shows how to set up a certificate authority using `openssl` and use it to generate client and server certificates for use with MongoDB.

## Usage

1. Clone the repo
1. Change directory to the cloned repo and start the container.
   ```
   cd mongotestcerts
   docker-compose up
   ```
1. Log into the container
   ```
   docker exec -it $(docker ps | grep 'mongodbtestcerts_mongotestcerts' | awk '{print $1}') /bin/sh
   ```
1. Check out the "Troubleshooting commands" section below to connect to the `mongod` instance and also inspect the certificate.

## Troubleshooting commands

### Get the subject name
```
openssl x509 -in /certs/client.pem -inform PEM -subject -nameopt RFC2253 | grep subject
```

### Verify if the server and client cert are signed by the CA
```
openssl verify -CAfile /certs/ca.pem /certs/server.pem
openssl verify -CAfile /certs/ca.pem /certs/client.pem
```

### Get some information on about the contents
```
openssl x509 -text -in /certs/server.pem
openssl x509 -text -in /certs/client.pem
```

### Test the connections
```
mongo --tls --tlsCertificateKeyFile /certs/client.pem --tlsCAFile /certs/ca.pem --authenticationMechanism MONGODB-X509 --authenticationDatabase '$external' --host 127.0.0.1

openssl s_client -connect `hostname -f`:27017 -CAfile /certs/ca.pem  -cert /certs/client.pem
```

## Reference

- [Appendix A - OpenSSL CA Certificate for Testing](https://docs.mongodb.com/manual/appendix/security/appendixA-openssl-ca/)
- [Appendix B - OpenSSL Server Certificates for Testing](https://docs.mongodb.com/manual/appendix/security/appendixB-openssl-server/)
- [Appendix C - OpenSSL Client Certificates for Testing](https://docs.mongodb.com/manual/appendix/security/appendixC-openssl-client/)
