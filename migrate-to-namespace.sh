#!/usr/bin/env bash

echo "=========================================="
echo "迁移 Nacos 和 MySQL 到 nacos 命名空间"
echo "=========================================="

# 1. 创建 nacos 命名空间
echo "1. 创建 nacos 命名空间..."
kubectl create namespace nacos

# 2. 导出当前配置
echo "2. 导出当前 default 命名空间的配置..."
kubectl get configmap nacos-cm -n default -o yaml > /tmp/nacos-cm-backup.yaml

# 3. 删除 default 命名空间的资源
echo "3. 删除 default 命名空间的 Nacos 和 MySQL..."
kubectl delete statefulset nacos -n default
kubectl delete service nacos-headless -n default
kubectl delete configmap nacos-cm -n default
kubectl delete replicationcontroller mysql -n default
kubectl delete service mysql -n default

# 4. 等待资源删除
echo "4. 等待资源完全删除..."
sleep 5

# 5. 部署到 nacos 命名空间
echo "5. 部署 MySQL 到 nacos 命名空间..."
kubectl apply -f ./deploy/mysql/mysql-local.yaml -n nacos

echo "6. 等待 MySQL 启动..."
sleep 10

# 7. 获取 MySQL Pod 名称并导入 schema
echo "7. 导入数据库 schema..."
MYSQL_POD=$(kubectl get pods -n nacos -l name=mysql -o jsonpath='{.items[0].metadata.name}')
echo "MySQL Pod: $MYSQL_POD"
kubectl exec -i $MYSQL_POD -n nacos -- mysql -unacos -pnacos nacos_devtest < /data/mysql-init/mysql-schema.sql

# 8. 部署 Nacos 到 nacos 命名空间
echo "8. 部署 Nacos 集群到 nacos 命名空间..."
kubectl apply -f ./deploy/nacos/nacos-quick-start.yaml -n nacos

echo ""
echo "=========================================="
echo "验证部署"
echo "=========================================="

# 等待 Pod 启动
echo "等待 Pod 启动..."
sleep 15

echo ""
echo "MySQL 状态："
kubectl get pods -n nacos -l name=mysql

echo ""
echo "Nacos 状态："
kubectl get pods -n nacos -l app=nacos

echo ""
echo "Service 状态："
kubectl get service -n nacos

echo ""
echo "=========================================="
echo "迁移完成！"
echo "=========================================="
echo "所有资源现在都在 nacos 命名空间下"
echo "查看资源: kubectl get all -n nacos"
echo "=========================================="
