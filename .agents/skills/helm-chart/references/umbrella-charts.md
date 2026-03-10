# Umbrella Chart Patterns

Umbrella charts (meta-charts) bundle multiple sub-charts as dependencies to deploy complete application stacks.

## Structure

```
myapp-umbrella/
├── Chart.yaml
├── values.yaml
├── charts/           # Sub-charts (dependencies)
│   ├── frontend/
│   ├── backend/
│   └── database/
└── templates/
    └── NOTES.txt     # Optional: aggregated instructions
```

## Chart.yaml Dependencies

```yaml
apiVersion: v2
name: myapp
version: 1.0.0
type: application

dependencies:
  # Local sub-chart
  - name: frontend
    version: "1.x.x"
    repository: "file://charts/frontend"
  
  # Remote repository
  - name: backend
    version: "2.3.4"
    repository: "https://charts.example.com"
  
  # OCI registry
  - name: database
    version: "5.0.0"
    repository: "oci://registry.example.com/charts"
  
  # Conditional dependency
  - name: monitoring
    version: "1.0.0"
    repository: "https://prometheus-community.github.io/helm-charts"
    condition: monitoring.enabled
  
  # Alias for multiple instances
  - name: redis
    version: "17.0.0"
    repository: "https://charts.bitnami.com/bitnami"
    alias: cache
  
  - name: redis
    version: "17.0.0"
    repository: "https://charts.bitnami.com/bitnami"
    alias: session
```

## Dependency Management

```bash
# Download dependencies to charts/
helm dependency update ./myapp-umbrella

# List dependencies
helm dependency list ./myapp-umbrella

# Build (update + package)
helm dependency build ./myapp-umbrella
```

## Values Propagation

### Scoped Values (Default)

Sub-chart values are namespaced by chart name:

```yaml
# values.yaml
frontend:
  replicaCount: 3
  image:
    tag: "v2.0.0"

backend:
  replicaCount: 2
  config:
    debug: false

# Aliased chart uses alias name
cache:
  auth:
    enabled: false
```

### Global Values

Shared across all sub-charts:

```yaml
global:
  imageRegistry: "myregistry.example.com"
  imagePullSecrets:
    - name: regcred
  storageClass: "fast-ssd"
```

Access in sub-chart templates:
```yaml
image: {{ .Values.global.imageRegistry }}/{{ .Values.image.repository }}
```

### Import Values

Import sub-chart exports into parent:

```yaml
# Sub-chart (backend) Chart.yaml
exports:
  - data:
      apiEndpoint: "http://backend:8080"

# Parent Chart.yaml
dependencies:
  - name: backend
    import-values:
      - data
```

## Common Patterns

### 1. Application Stack

```yaml
# Chart.yaml
dependencies:
  - name: app
    version: "1.0.0"
    repository: "file://charts/app"
  - name: postgresql
    version: "12.0.0"
    repository: "https://charts.bitnami.com/bitnami"
  - name: redis
    version: "17.0.0"
    repository: "https://charts.bitnami.com/bitnami"

# values.yaml
app:
  database:
    host: "{{ .Release.Name }}-postgresql"
  redis:
    host: "{{ .Release.Name }}-redis-master"

postgresql:
  auth:
    database: myapp
    username: myapp

redis:
  auth:
    enabled: false
```

### 2. Environment-Specific Overlays

```
myapp-umbrella/
├── Chart.yaml
├── values.yaml              # Base/defaults
├── values-dev.yaml          # Development overrides
├── values-staging.yaml      # Staging overrides
└── values-prod.yaml         # Production overrides
```

```bash
helm install myapp ./myapp-umbrella -f values-prod.yaml
```

### 3. Optional Components

```yaml
# Chart.yaml
dependencies:
  - name: monitoring
    condition: monitoring.enabled
  - name: logging
    condition: logging.enabled
    tags:
      - observability

# values.yaml
monitoring:
  enabled: false

logging:
  enabled: false

tags:
  observability: false  # Disable all tagged deps
```

### 4. Cross-Chart References

Use named templates in parent for consistency:

```yaml
# templates/_helpers.tpl
{{- define "myapp.databaseHost" -}}
{{ .Release.Name }}-postgresql
{{- end }}

{{- define "myapp.redisHost" -}}
{{ .Release.Name }}-redis-master
{{- end }}
```

Pass via global values:
```yaml
global:
  database:
    host: '{{ include "myapp.databaseHost" . }}'
```

## Best Practices

### Do

- **Version pin dependencies** - use exact versions or tight ranges
- **Use conditions** for optional components
- **Document sub-chart configurations** in parent values.yaml
- **Test upgrade paths** - sub-chart upgrades can break
- **Use global values** for shared config (registry, secrets)

### Don't

- **Don't nest too deep** - max 2-3 levels
- **Don't duplicate values** - use globals or imports
- **Don't bypass sub-chart values** - respect their interface
- **Don't mix local and remote** without reason

## Upgrading Dependencies

```bash
# Check for updates
helm dependency list ./myapp-umbrella

# Update Chart.yaml versions, then:
helm dependency update ./myapp-umbrella

# Test before deploy
helm upgrade --install --dry-run myapp ./myapp-umbrella
```

## Troubleshooting

### Dependency not found

```bash
# Ensure repo is added
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Re-download
helm dependency update ./myapp-umbrella
```

### Values not propagating

Check namespace:
```yaml
# Wrong: top-level
replicaCount: 3

# Correct: scoped to sub-chart
frontend:
  replicaCount: 3
```

### Conflicting resource names

Use fullnameOverride per sub-chart:
```yaml
frontend:
  fullnameOverride: "myapp-frontend"
backend:
  fullnameOverride: "myapp-backend"
```
