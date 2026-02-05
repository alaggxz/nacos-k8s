#!/usr/bin/env bash

echo "=========================================="
echo "清理旧的 Nacos 单机部署"
echo "=========================================="

# 删除旧的 StatefulSet
echo "1. 删除旧的 Nacos StatefulSet..."
kubectl delete statefulset nacos --ignore-not-found=true

# 删除旧的 Service
echo "2. 删除旧的 Nacos Service..."
kubectl delete service nacos --ignore-not-found=true

# 删除旧的 ConfigMap
echo "3. 删除旧的 Nacos ConfigMap..."
kubectl delete configmap nacos-config --ignore-not-found=true

# 删除旧的 PVC（如果存在）
echo "4. 删除旧的 PVC..."
kubectl delete pvc nfs-nacos --ignore-not-found=true

# 等待资源完全删除
echo "5. 等待资源完全删除..."
sleep 5

echo ""
echo "=========================================="
echo "部署新的 Nacos 集群（3节点）"
echo "=========================================="

# 执行快速启动脚本
./quick-startup.sh

echo ""
echo "=========================================="
echo "验证部署状态"
echo "=========================================="

# 等待 Pod 启动
echo "等待 Pod 启动（最多等待 60 秒）..."
kubectl wait --for=condition=ready pod -l app=nacos --timeout=60s

# 显示部署状态
echo ""
echo "StatefulSet 状态："
kubectl get statefulsets nacos

echo ""
echo "Pod 状态："
kubectl get pods -l app=nacos -o wide

echo ""
echo "Service 状态："
kubectl get service nacos-headless

echo ""
echo "=========================================="
echo "验证配置"
echo "=========================================="

# 检查镜像版本
echo "Nacos 镜像版本："
kubectl get pods -l app=nacos -o jsonpath='{.items[0].spec.containers[0].image}'
echo ""

# 检查认证环境变量
echo ""
echo "认证环境变量："
kubectl exec nacos-0 -- env | grep NACOS_AUTH || echo "等待 Pod 完全启动..."

echo ""
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo "Nacos 控制台访问地址："
echo "  http://<node-ip>:8848/nacos"
echo ""
echo "默认用户名/密码: nacos/nacos"
echo "=========================================="
