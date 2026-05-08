# AUDIT.md

# Security Findings

## Helm Deployment

### Finding: Secret managed as plain Terraform variable
- File: terraform/main.tf
- Issue: API token may be stored in Terraform state in readable form
- Risk: Secret exposure through shared state files or logs
- Fix: Mark variables as sensitive and restrict state access

### Finding: Secret stored in Helm values file
- File: helm/skybyte-app/values.yaml
- Issue: API token stored directly in values.yaml
- Risk: Secret exposure through Git history, Helm release metadata, and repository access
- Fix: Move secret to Kubernetes Secret managed via Terraform and reference via secretKeyRef

### Finding: Deployment injects secret as plain environment value
- File: helm/skybyte-app/templates/deployment.yaml
- Issue: Secret value injected directly from Helm values
- Risk: Secret exposed in rendered manifests and Helm history
- Fix: Use Kubernetes Secret reference via env.valueFrom.secretKeyRef

### Finding: Floating latest image tag
- File: helm/skybyte-app/values.yaml
- Issue: Image tag uses latest
- Risk: Non-reproducible deployments and unexpected upgrades
- Fix: Pin explicit immutable image version

### Finding: No container securityContext
- File: helm/skybyte-app/templates/deployment.yaml
- Issue: No security hardening settings configured
- Risk: Container may run with elevated privileges and writable filesystem
- Fix: Add runAsNonRoot, readOnlyRootFilesystem, seccompProfile, dropped capabilities, and allowPrivilegeEscalation=false

## Dockerfile

### Finding: Unpinned floating base image
- File: Dockerfile
- Issue: Uses `python:3.9` without digest pinning or slim variant
- Risk: Pulls changing upstream layers over time and increases attack surface
- Fix: Use a pinned minimal image such as `python:3.12-slim`

### Finding: Container runs as root
- File: Dockerfile
- Issue: No USER directive defined
- Risk: Compromise inside container becomes full root inside container namespace
- Fix: Create dedicated non-root UID and run application with USER

### Finding: pip cache retained in image
- File: Dockerfile
- Issue: pip install runs without --no-cache-dir
- Risk: Larger image size and unnecessary package cache retained
- Fix: Use pip install --no-cache-dir

# Reliability Findings
## Kubernetes Deployment

### Finding: Missing resource requests and limits
- File: helm/skybyte-app/templates/deployment.yaml
- Issue: No CPU or memory requests/limits defined
- Risk: Pod starvation, noisy neighbor impact, and scheduler unpredictability
- Fix: Define appropriate requests and limits

### Finding: Probes use defaults without thresholds
- File: helm/skybyte-app/templates/deployment.yaml
- Issue: Liveness and readiness probes missing timeout and threshold tuning
- Risk: False positives during startup or transient latency
- Fix: Configure initialDelaySeconds, timeoutSeconds, periodSeconds, and failureThreshold

### Finding: Probes use root endpoint only
- File: helm/skybyte-app/templates/deployment.yaml
- Issue: Health probes target application root endpoint
- Risk: Cannot distinguish application health from business endpoint behavior
- Fix: Add dedicated /health and /ready endpoints

### Finding: No graceful shutdown handling
- File: helm/skybyte-app/templates/deployment.yaml
- Issue: No terminationGracePeriodSeconds or SIGTERM handling
- Risk: In-flight request drops during rolling updates
- Fix: Implement SIGTERM handling and readiness drain logic

# Hygiene Findings
## CI Pipeline

### Finding: flake8 configured to ignore failures
- File: .github/workflows/ci.yml
- Issue: flake8 runs with --exit-zero
- Risk: Pipeline reports success even with lint violations
- Fix: Remove --exit-zero

### Finding: Helm lint failures ignored
- File: .github/workflows/ci.yml
- Issue: helm lint command ends with || true
- Risk: Broken manifests still pass CI
- Fix: Fail pipeline on Helm validation errors

### Finding: Terraform validate failures ignored
- File: .github/workflows/ci.yml
- Issue: terraform validate command ends with || true
- Risk: Invalid infrastructure changes reach deployment stage
- Fix: Remove failure suppression

### Finding: No Kubernetes manifest schema validation
- File: .github/workflows/ci.yml
- Issue: No kubeconform or kubeval validation
- Risk: Invalid manifests detected only at deployment time
- Fix: Add kubeconform validation step

### Finding: No security scanning in CI
- File: .github/workflows/ci.yml
- Issue: No filesystem or image vulnerability scanning
- Risk: Vulnerable dependencies and images shipped undetected
- Fix: Add Trivy filesystem and image scanning

### Finding: No policy validation in CI
- File: .github/workflows/ci.yml
- Issue: No Kyverno policy enforcement during pipeline
- Risk: Security regressions not blocked before deployment
- Fix: Run kyverno apply against rendered manifests

# Documentation Findings
## Repository Documentation

### Finding: README outdated
- File: README.md
- Issue: Repository documentation does not reflect actual deployment behavior or security model
- Risk: Operational confusion and onboarding friction
- Fix: Rewrite README with accurate deployment, observability, and operational instructions
