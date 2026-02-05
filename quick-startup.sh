#!/usr/bin/env bash

echo "mysql mysql startup"
sh deploy/mysql/mysql-init.sh && kubectl apply -f ./deploy/mysql/mysql-local.yaml


echo "nacos quick startup"
kubectl apply -f ./deploy/nacos/nacos-quick-start.yaml
