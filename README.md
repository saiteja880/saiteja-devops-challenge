# Skybyte API – DevOps Challenge Submission

## Overview

This project is a containerized Python service deployed on Kubernetes using Helm, Terraform, and GitHub Actions CI/CD pipeline.

It demonstrates:
- Kubernetes security hardening
- Policy-as-code (Kyverno)
- Observability with Prometheus metrics
- Infrastructure as Code (Terraform)
- CI/CD validation pipeline

---

## Application

- Language: Python (Flask)
- Endpoint: `/`
- Health: `/health`
- Readiness: `/ready`
- Metrics: `/metrics`

Example response:

```json
{"message":"Hello, Candidate","version":"1.0.0"}


## Architecture

Client → Kubernetes Service (ClusterIP) → Pod (non-root container)

The application is accessed internally using Kubernetes DNS:

http://skybyte-app:8080

or

http://skybyte-app.devops-challenge.svc.cluster.local:8080

## SLO (Service Level Objective)

99% of requests to `/` should complete in under 200ms over a rolling 7-day window.

This ensures the service remains responsive under normal Kubernetes cluster load and during deployments.

We use Prometheus metrics from `/metrics` endpoint to monitor this.
