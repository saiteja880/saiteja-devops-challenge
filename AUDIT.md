# AUDIT.md

# Security Findings

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

# Hygiene Findings

# Documentation Findings
