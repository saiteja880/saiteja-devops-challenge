#!/bin/bash

set -e

echo "🚀 Starting Skybyte DevOps setup..."

# ---------------------------
# Check prerequisites
# ---------------------------
echo "🔍 Checking kubectl..."
kubectl version --client

echo "🔍 Checking helm..."
helm version

echo "🔍 Checking docker..."
docker version

# ---------------------------
# Terraform
# ---------------------------
echo "⚙️ Running Terraform..."

cd terraform
terraform init -backend=false
terraform apply -auto-approve
cd ..

# ---------------------------
# Kubernetes namespace check
# ---------------------------
echo "📦 Verifying namespace..."
kubectl get ns devops-challenge || kubectl create ns devops-challenge

# ---------------------------
# Kyverno install (if not exists)
# ---------------------------
echo "🛡️ Ensuring Kyverno is installed..."

helm repo add kyverno https://kyverno.github.io/kyverno/ || true
helm repo update

helm list -n kyverno | grep kyverno || \
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

# ---------------------------
# Apply policies
# ---------------------------
echo "📜 Applying policies..."
kubectl apply -f policies/

# ---------------------------
# Helm deploy
# ---------------------------
echo "🚢 Deploying application..."

helm upgrade --install skybyte-app helm/skybyte-app \
  --namespace devops-challenge

# ---------------------------
# Wait for rollout
# ---------------------------
echo "⏳ Waiting for rollout..."
kubectl rollout status deployment/skybyte-app -n devops-challenge

# ---------------------------
# Done
# ---------------------------
echo "✅ Setup complete!"
echo "👉 Run system-checks.sh next"
