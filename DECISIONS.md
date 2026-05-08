# Engineering Decisions

## Decision 1: Non-root container execution
**Context:** Default Python containers run as root  
**Options considered:** root vs non-root user  
**Chosen:** non-root user (UID 10001)  
**Rationale:** reduces container breakout risk and aligns with Kubernetes security best practices  
**Tradeoff:** slight complexity in file permissions and debugging  

---

## Decision 2: Slim base image
**Context:** Default Python images are large and include unnecessary tools  
**Options considered:** python:3.12 vs slim vs distroless  
**Chosen:** python:3.12-slim  
**Rationale:** reduced attack surface while maintaining usability for debugging  
**Tradeoff:** not fully distroless, still includes minimal OS tools  

---

## Decision 3: Kubernetes Secrets via Terraform
**Context:** Secrets were initially stored in Helm values (unsafe)  
**Options considered:** Helm values vs External Secrets vs Terraform  
**Chosen:** Kubernetes Secret managed via Terraform  
**Rationale:** avoids secret exposure in Git history and Helm releases  
**Tradeoff:** less dynamic compared to External Secrets Operator  

---

## Decision 4: Helm for deployment
**Context:** Need reusable Kubernetes manifests  
**Options considered:** raw YAML vs Helm vs Kustomize  
**Chosen:** Helm  
**Rationale:** enables templating and environment reusability  
**Tradeoff:** increases template complexity  

---

## Decision 5: Kyverno for policy enforcement
**Context:** Need admission control for security standards  
**Options considered:** Kyverno vs Gatekeeper  
**Chosen:** Kyverno  
**Rationale:** Kubernetes-native YAML policies and easy integration  
**Tradeoff:** less expressive than Rego-based policies  

---

## Decision 6: Prometheus-style metrics
**Context:** Need observability and request tracking  
**Options considered:** logging only vs custom metrics vs Prometheus client  
**Chosen:** Prometheus metrics endpoint (`/metrics`)  
**Rationale:** industry-standard observability approach  
**Tradeoff:** added dependency and verbosity  

---

## Decision 7: Resource requests and limits
**Context:** Prevent resource starvation and ensure scheduling stability  
**Options considered:** no limits vs static limits vs autoscaling  
**Chosen:** static requests and limits  
**Rationale:** predictable scheduling and Kyverno compliance  
**Tradeoff:** not dynamically optimized like HPA  

---

## Decision 8: CI/CD enforcement strategy
**Context:** Initial CI allowed failures using `|| true`  
**Options considered:** soft CI vs strict CI  
**Chosen:** strict CI (fail-fast approach)  
**Rationale:** ensures broken code does not reach deployment stage  
**Tradeoff:** slower development iteration during early changes  

---

## Decision 9: Kubernetes Service access model
**Context:** Application access required for internal communication  
**Options considered:** NodePort vs LoadBalancer vs ClusterIP  
**Chosen:** ClusterIP  
**Rationale:** internal-only communication is sufficient for challenge scope  
**Tradeoff:** no external exposure without port-forwarding  

---

## Decision 10: Debugging strategy inside cluster
**Context:** Port-forwarding and kubectl exec with tools like curl were not reliable due to minimal images and policy restrictions  
**Options considered:** port-forward vs exec vs debug pods  
**Chosen:** Kubernetes DNS + Kyverno-compliant debug pods  
**Rationale:** production-like internal testing using service DNS (`skybyte-app:8080`)  
**Tradeoff:** requires compliant debug pod definitions  

---

## Decision 11: Security policy enforcement (Kyverno)
**Context:** Cluster requires security baseline enforcement  
**Policies enforced:**
- Non-root containers required  
- CPU and memory requests/limits required  

**Rationale:** ensures secure and predictable workloads at admission level  
**Tradeoff:** requires extra configuration for debug workloads  

---

## Decision 12: Infrastructure as Code (Terraform)
**Context:** Need consistent cluster resources  
**Resources managed:**
- Namespace  
- ResourceQuota  
- Secrets  

**Rationale:** ensures reproducible infrastructure setup  
**Tradeoff:** additional operational layer compared to manual kubectl  

---

## Conclusion

This system is designed to be:

- Secure (Kyverno + non-root + hardened containers)
- Reliable (health checks + resource limits)
- Observable (Prometheus metrics)
- Reproducible (Terraform + Helm)
- CI-enforced (GitHub Actions pipeline)
- Production-like (DNS-based internal service access)
