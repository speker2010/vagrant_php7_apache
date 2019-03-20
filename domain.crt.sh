#!/bin/bash

openssl genrsa -out $1.key 2048
cat domain.cfg.default | sed "s/site.com/$1/g" > domain.cfg
openssl req -new -key $1.key -config domain.cfg -out $1.csr
openssl x509 -req -in $1.csr -CA myRootCA.crt -CAkey myRootCA.key -CAcreateserial -out $1.crt -days 5000 -extensions v3_req -extfile domain.cfg
rm -rf domain.cfg
