#!/bin/bash

openssl genrsa -out myRootCA.key 4096
openssl req -x509 -new -key myRootCA.key -days 10000 -config root.cfg -out myRootCA.crt
