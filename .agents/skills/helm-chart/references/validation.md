# Validation & Quality Assurance

## Helm Debugging

### Basic Commands

```bash
# Lint: verify chart follows best practices
helm lint ./mychart
helm lint ./mychart --strict   # Treat warnings as errors

# Template locally (no cluster needed)
helm template ./mychart
helm template ./mychart --debug           # Show computed values
helm template ./mychart -f custom.yaml    # With custom values

# Dry-run against cluster (checks conflicts, runs lookups)
helm install --dry-run --debug myrelease ./mychart
helm install --dry-run=server myrelease ./mychart  # Server-side validation + lookup

# Inspect installed release
helm get manifest myrelease
helm get values myrelease
```

### Debugging Broken YAML

Comment out problematic sections to isolate issues:
```yaml
apiVersion: v2
# some: problem section
# {{ .Values.foo | quote }}
```

Re-run `helm template --debug` - comments render with values resolved.

---

## kubeconform

**Purpose**: Fast Kubernetes manifest validation against JSON schemas. Supports CRDs.

### Installation

```bash
brew install kubeconform
# or
go install github.com/yannh/kubeconform/cmd/kubeconform@latest
```

### Helm Integration

```bash
# Validate rendered templates
helm template ./mychart | kubeconform -strict -summary

# Specify Kubernetes version
helm template ./mychart | kubeconform -kubernetes-version 1.29.0 -strict

# Multiple workers for speed
helm template ./mychart | kubeconform -n 8 -summary

# JSON output for CI
helm template ./mychart | kubeconform -output json
```

### CRD Support

```bash
# Use Datree's CRD catalog for common CRDs
helm template ./mychart | kubeconform \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

# Local CRD schemas
kubeconform -schema-location 'schemas/{{ .ResourceKind }}{{ .KindSuffix }}.json' manifest.yaml
```

### Key Options

| Flag | Purpose |
|------|---------|
| `-strict` | Disallow additional properties |
| `-ignore-missing-schemas` | Skip unknown CRDs instead of failing |
| `-summary` | Print validation summary |
| `-kubernetes-version` | Target K8s version (default: master) |
| `-n` | Parallel workers (default: 4) |
| `-output` | json, junit, tap, text (default: text) |

---

## Trivy

**Purpose**: Security scanner for misconfigurations, vulnerabilities, secrets.

### Installation

```bash
brew install trivy
# or
docker run aquasec/trivy
```

### Helm Chart Scanning

```bash
# Scan chart directory for misconfigs
trivy config ./mychart

# Scan rendered manifests
helm template ./mychart > manifests.yaml
trivy config manifests.yaml

# Multiple scanners
trivy fs --scanners vuln,secret,misconfig ./mychart

# JSON output for CI
trivy config --format json --output results.json ./mychart
```

### Common Findings

Trivy checks for:

- **Misconfigurations**: Running as root, missing resource limits, privilege escalation
- **Secrets**: Hardcoded passwords, API keys in templates
- **Known CVEs**: If scanning container images referenced in values

### Severity Filtering

```bash
# Only critical/high issues
trivy config --severity CRITICAL,HIGH ./mychart

# Exit code on findings (for CI)
trivy config --exit-code 1 ./mychart
```

---

## Pluto

**Purpose**: Detect deprecated/removed Kubernetes API versions.

### Installation

```bash
brew install FairwindsOps/tap/pluto
# or
go install github.com/FairwindsOps/pluto/v5/cmd/pluto@latest
```

### Helm Integration

```bash
# Scan rendered templates
helm template ./mychart | pluto detect -

# Scan chart directory
pluto detect-files -d ./mychart/templates

# Target specific K8s version
helm template ./mychart | pluto detect --target-versions k8s=v1.29.0 -

# Check installed Helm releases
pluto detect-helm --helm-version 3
```

### Output Format

```bash
# Detailed output
pluto detect-files -d ./mychart -o wide

# JSON for CI
pluto detect-files -d ./mychart -o json

# Markdown for docs
pluto detect-files -d ./mychart -o markdown
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | No deprecated/removed APIs |
| 1 | Error during execution |
| 2 | Deprecated APIs found |
| 3 | Removed APIs found |

---

## Complete Validation Pipeline

```bash
#!/bin/bash
set -e

CHART_DIR="${1:-.}"
K8S_VERSION="${2:-1.29.0}"

echo "=== Helm Lint ==="
helm lint "$CHART_DIR" --strict

echo "=== Template Generation ==="
helm template "$CHART_DIR" > /tmp/manifests.yaml

echo "=== Schema Validation (kubeconform) ==="
kubeconform -strict -summary \
  -kubernetes-version "$K8S_VERSION" \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
  /tmp/manifests.yaml

echo "=== Deprecated API Check (pluto) ==="
pluto detect --target-versions "k8s=v$K8S_VERSION" - < /tmp/manifests.yaml

echo "=== Security Scan (trivy) ==="
trivy config --severity HIGH,CRITICAL --exit-code 1 /tmp/manifests.yaml

echo "=== All validations passed ==="
```

---

## Chart Testing (ct)

**Purpose**: Official Helm tool for linting and testing charts in monorepos. Auto-detects changed charts, enforces SemVer.

### Installation

```bash
# Binary
wget https://github.com/helm/chart-testing/releases/latest/download/chart-testing_linux_amd64.tar.gz
tar xzf chart-testing_linux_amd64.tar.gz

# Docker
docker pull quay.io/helmpack/chart-testing
```

### Commands

```bash
# Lint changed charts against target branch
ct lint --target-branch main

# Lint specific charts
ct lint --charts ./charts/myapp

# Lint all charts
ct lint --all

# Install and test in cluster
ct install --target-branch main

# Lint + install
ct lint-and-install --target-branch main

# List changed charts
ct list-changed --target-branch main
```

### Configuration (ct.yaml)

```yaml
# ct.yaml
chart-dirs:
  - charts

chart-repos:
  - bitnami=https://charts.bitnami.com/bitnami

target-branch: main
remote: origin

helm-extra-args: --timeout 600s

# Validate Chart.yaml schema
validate-chart-schema: true
validate-maintainers: true
```

### CI Values Files

Place test values in `ci/` directory:
```
mychart/
├── Chart.yaml
├── values.yaml
└── ci/
    ├── test-values.yaml       # Tested automatically
    └── prod-values.yaml       # Also tested
```

### Upgrade Testing

```bash
# Test upgrade from previous version (SemVer-aware)
ct install --upgrade --target-branch main
```

Only runs upgrade test if version change is non-breaking (patch/minor).

---

## Helm Test Hooks

Built-in chart testing via test pods:

```yaml
# templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "mychart.fullname" . }}-test-connection"
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['{{ include "mychart.fullname" . }}:{{ .Values.service.port }}']
  restartPolicy: Never
```

```bash
# Run after install
helm test myrelease

# Run with timeout
helm test myrelease --timeout 5m
```

---

## CI Integration Examples

### GitHub Actions (Full ct Workflow)

```yaml
name: Lint and Test Charts
on: pull_request

jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: azure/setup-helm@v4

      - uses: actions/setup-python@v5
        with:
          python-version: '3.x'

      - uses: helm/chart-testing-action@v2.8.0

      - name: List changed charts
        id: list-changed
        run: |
          changed=$(ct list-changed --target-branch ${{ github.event.repository.default_branch }})
          if [[ -n "$changed" ]]; then
            echo "changed=true" >> "$GITHUB_OUTPUT"
          fi

      - name: Lint charts
        if: steps.list-changed.outputs.changed == 'true'
        run: ct lint --target-branch ${{ github.event.repository.default_branch }}

      - name: Create kind cluster
        if: steps.list-changed.outputs.changed == 'true'
        uses: helm/kind-action@v1.12.0

      - name: Install and test charts
        if: steps.list-changed.outputs.changed == 'true'
        run: ct install --target-branch ${{ github.event.repository.default_branch }}
```

### GitHub Actions (Quick Validation)

```yaml
- name: Validate Helm Chart
  run: |
    helm template ./mychart > manifests.yaml
    kubeconform -strict -summary manifests.yaml
    pluto detect - < manifests.yaml
    trivy config --exit-code 1 manifests.yaml
```

### GitLab CI

```yaml
stages:
  - lint
  - test

lint-charts:
  stage: lint
  image: quay.io/helmpack/chart-testing:latest
  script:
    - ct lint --all --chart-dirs charts/

test-charts:
  stage: test
  image: quay.io/helmpack/chart-testing:latest
  services:
    - docker:dind
  before_script:
    - kind create cluster
  script:
    - ct install --all --chart-dirs charts/
```

### Local Development

```bash
# Quick iteration
helm lint ./mychart && helm template ./mychart | kubeconform -strict

# Full local test (requires cluster)
ct lint-and-install --charts ./mychart
```
