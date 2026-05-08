#!/bin/bash

echo "🔍 Running Skybyte system checks..."

NAMESPACE="devops-challenge"

POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=skybyte-app -o jsonpath="{.items[0].metadata.name}")

echo "📦 Target Pod: $POD"

echo "👤 Checking container user..."
kubectl exec -n $NAMESPACE $POD -- id

echo "⚙️ Checking main process..."
kubectl exec -n $NAMESPACE $POD -- ps -ef | head -n 2

BASE_URL="http://skybyte-app:8080"

echo "🌐 Root endpoint..."
kubectl exec -n $NAMESPACE $POD -- curl -s $BASE_URL/

echo "❤️ Health endpoint..."
kubectl exec -n $NAMESPACE $POD -- curl -s $BASE_URL/health

echo "🟢 Readiness endpoint..."
kubectl exec -n $NAMESPACE $POD -- curl -s $BASE_URL/ready

echo "📊 Metrics check..."
kubectl exec -n $NAMESPACE $POD -- curl -s $BASE_URL/metrics | grep http_requests_total

echo "♻️ Restart test..."
kubectl delete pod $POD -n $NAMESPACE

echo "⏳ Waiting for recovery..."
sleep 25

kubectl get pods -n $NAMESPACE

echo "✅ DONE"
