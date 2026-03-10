---
name: helm-chart
description: Generate production-ready Helm charts following official best practices. Use when creating Kubernetes Helm charts, chart templates, values.yaml files, or _helpers.tpl. Triggers on requests for Helm chart generation, Kubernetes packaging, or chart template development.
---

# Helm Chart Generation

Generate production-ready Helm charts following official Helm best practices.

## Chart Structure

```
mychart/
├── Chart.yaml          # Required: chart metadata
├── values.yaml         # Default configuration values
├── charts/             # Dependencies
├── crds/               # CRD definitions (not templated)
├── templates/
│   ├── NOTES.txt       # Post-install instructions
│   ├── _helpers.tpl    # Template helpers
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── serviceaccount.yaml
│   ├── hpa.yaml
│   └── tests/
│       └── test-connection.yaml
└── .helmignore
```

## Naming Conventions

**Chart names**: lowercase letters, numbers, hyphens only. Start with letter.
```
✓ nginx-ingress, aws-cluster-autoscaler
✗ Nginx_Ingress, 1st-chart
```

**Template files**: dashed notation, reflect resource kind.
```
✓ foo-deployment.yaml, bar-svc.yaml
✗ fooDeployment.yaml, bar.yaml
```

**Values**: camelCase, lowercase start. No hyphens.
```yaml
# ✓ Correct
replicaCount: 1
image:
  repository: nginx
  pullPolicy: IfNotPresent

# ✗ Incorrect
ReplicaCount: 1      # conflicts with built-ins
replica-count: 1     # hyphens break templates
```

## Template Formatting

```yaml
# Whitespace after {{ and before }}
{{ .Values.foo }}           # ✓
{{.Values.foo}}             # ✗

# Chomp whitespace with -
{{- if .Values.enabled }}
  key: value
{{- end }}

# Two-space indentation, never tabs
```

## Essential _helpers.tpl

```yaml
{{/*
Chart name, truncated to 63 chars (DNS limit)
*/}}
{{- define "mychart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name. Release + chart name, max 63 chars.
*/}}
{{- define "mychart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mychart.labels" -}}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "mychart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (immutable for Deployments)
*/}}
{{- define "mychart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Chart label
*/}}
{{- define "mychart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "mychart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mychart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
```

## Labels vs Annotations

**Labels**: For identification and querying. Used by Kubernetes selectors.
**Annotations**: For non-identifying metadata. Not used for selection.

## Standard Labels

| Label | Status | Description |
|-------|--------|-------------|
| `app.kubernetes.io/name` | **REC** | App name: `{{ template "name" . }}` |
| `app.kubernetes.io/instance` | **REC** | Release: `{{ .Release.Name }}` |
| `app.kubernetes.io/version` | OPT | App version: `{{ .Chart.AppVersion }}` |
| `app.kubernetes.io/managed-by` | **REC** | Always: `{{ .Release.Service }}` |
| `helm.sh/chart` | **REC** | Chart identifier: `{{ .Chart.Name }}-{{ .Chart.Version }}` |
| `app.kubernetes.io/component` | OPT | Role in app: `frontend`, `backend`, `database` |
| `app.kubernetes.io/part-of` | OPT | Parent application name (for multi-chart apps) |

**REC** = Recommended (should always include), **OPT** = Optional

## Values Best Practices

See `references/values-patterns.md` for comprehensive patterns from Bitnami, ArgoCD, Grafana charts.

### When to Use Subtrees vs Flat Values

**Subtrees for K8s API objects** - Users `toYaml` entire sections:
```yaml
# ✓ Correct: subtree mirrors K8s API
resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 128Mi

podSecurityContext: {}
  # fsGroup: 2000

# ✗ Wrong: flat values for structured objects
resourceLimitsCpu: 100m
resourceLimitsMemory: 128Mi
```

**Flat for simple values**:
```yaml
# ✓ Correct: single values stay flat
replicaCount: 1
revisionHistoryLimit: 3
```

### Empty Defaults `{}`

Allow users to override entire sections or leave empty:
```yaml
resources: {}           # User provides full spec or nothing
nodeSelector: {}
tolerations: []
affinity: {}
```

### Maps over Arrays (for `--set` compatibility)

```yaml
# ✓ Easy: --set servers.foo.port=80
servers:
  foo:
    port: 80

# ✗ Hard: --set servers[0].port=80
servers:
  - name: foo
    port: 80
```

### Document Every Value

```yaml
# -- Number of pod replicas
replicaCount: 1

image:
  # -- Container registry
  registry: docker.io
  # -- Image repository
  repository: nginx
  # -- Image tag (defaults to Chart.appVersion)
  tag: ""
```

## Standard values.yaml Structure

Industry-standard structure (matches `helm create` + Bitnami patterns):

```yaml
# -- Number of replicas
replicaCount: 1

# -- Revision history limit for deployments
revisionHistoryLimit: 3

image:
  # -- Container registry
  registry: docker.io
  # -- Image repository
  repository: nginx
  # -- Image tag (defaults to Chart.appVersion)
  tag: ""
  # -- Image pull policy
  pullPolicy: IfNotPresent

# -- Image pull secrets
imagePullSecrets: []
# - name: regcred

# -- Override chart name
nameOverride: ""
# -- Override full release name
fullnameOverride: ""

serviceAccount:
  # -- Create service account
  create: true
  # -- Automatically mount API credentials
  automount: true
  # -- Service account annotations
  annotations: {}
  # -- Service account name (auto-generated if empty)
  name: ""

# -- Pod annotations
podAnnotations: {}
# -- Pod labels (in addition to standard labels)
podLabels: {}

# -- Pod security context (applied to pod spec)
podSecurityContext: {}
  # fsGroup: 2000

# -- Container security context
securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

service:
  # -- Service type
  type: ClusterIP
  # -- Service port
  port: 80

ingress:
  # -- Enable ingress
  enabled: false
  # -- Ingress class name
  className: ""
  # -- Ingress annotations
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # cert-manager.io/cluster-issuer: letsencrypt
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  # -- TLS configuration
  tls: []
  # - secretName: chart-example-tls
  #   hosts:
  #     - chart-example.local

# -- Container resources
resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

livenessProbe:
  httpGet:
    path: /
    port: http
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10

autoscaling:
  # -- Enable HPA
  enabled: false
  # -- Minimum replicas
  minReplicas: 1
  # -- Maximum replicas
  maxReplicas: 100
  # -- Target CPU utilization
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

# -- Node selector
nodeSelector: {}

# -- Tolerations
tolerations: []

# -- Affinity rules
affinity: {}

# -- Extra environment variables
extraEnvVars: []
# - name: FOO
#   value: bar

# -- Extra volumes
extraVolumes: []

# -- Extra volume mounts
extraVolumeMounts: []
```

### Pattern: Subtrees for toYaml

```yaml
# Template
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 8 }}
{{- end }}

resources:
  {{- toYaml .Values.resources | nindent 12 }}
```

### Pattern: Enabled Flag + Config

```yaml
# values.yaml
metrics:
  enabled: false
  service:
    port: 9090
  serviceMonitor:
    enabled: false
    interval: 30s

# template
{{- if .Values.metrics.enabled }}
# metrics service/servicemonitor
{{- end }}
```

## RBAC Pattern

```yaml
# values.yaml
rbac:
  create: true

serviceAccount:
  create: true
  name: ""
```

```yaml
# templates/serviceaccount.yaml
{{- if .Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "mychart.serviceAccountName" . }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
```

## Image Configuration Pattern

```yaml
# values.yaml - use separate fields
image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: ""  # Overrides Chart.appVersion

# template
image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
imagePullPolicy: {{ .Values.image.pullPolicy }}
```

Never use `latest`, `head`, `canary` tags.

## PodTemplate Selector Pattern

Always declare explicit selectors (prevents breakage on label changes):
```yaml
spec:
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "mychart.selectorLabels" . | nindent 8 }}
```

## Flow Control

```yaml
# if/else
{{- if .Values.ingress.enabled }}
# ... ingress resource
{{- end }}

# with (changes scope)
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 8 }}
{{- end }}

# range
{{- range .Values.ingress.hosts }}
  - host: {{ .host | quote }}
{{- end }}

# Access parent scope in with/range
{{- with .Values.favorite }}
release: {{ $.Release.Name }}  # $ = root scope
{{- end }}
```

## Key Functions

See `references/functions.md` for full list. Most common:

| Function | Usage |
|----------|-------|
| `default` | `{{ .Values.name \| default "app" }}` |
| `quote` | `{{ .Values.env \| quote }}` |
| `toYaml` | `{{- toYaml .Values.resources \| nindent 12 }}` |
| `include` | `{{ include "mychart.name" . }}` |
| `required` | `{{ required "msg" .Values.key }}` |
| `tpl` | `{{ tpl .Values.template . }}` |
| `lookup` | `{{ lookup "v1" "Secret" "ns" "name" }}` |

## Validation & Debugging

See `references/validation.md` for full validation pipeline with all tools.

### Quick Validation

```bash
# Lint for best practices
helm lint ./mychart --strict

# Template locally + debug
helm template ./mychart --debug

# Schema validation (kubeconform)
helm template ./mychart | kubeconform -strict -summary -kubernetes-version 1.29.0

# Deprecated API detection (pluto)
helm template ./mychart | pluto detect -

# Security scan (trivy)
trivy config ./mychart --severity HIGH,CRITICAL

# Server-side dry-run (validates against cluster)
helm install --dry-run=server myrelease ./mychart
```

### Debugging Tips

- `helm template --debug` shows computed values
- Comment out broken sections, re-template to see rendered output
- `helm get manifest <release>` shows what's actually deployed
- kubeconform `-ignore-missing-schemas` skips unknown CRDs

## Common Pitfalls

See `references/common-pitfalls.md` for detailed patterns. Key issues:

1. **Whitespace errors** - use `{{-` and `-}}` carefully
2. **Type coercion** - quote strings, use `{{ int $val }}` for numbers
3. **Nested value checks** - each level needs existence check
4. **Selector immutability** - don't include mutable labels in selectors
5. **YAML comments in templates** - `#` comments render, use `{{/* */}}` for template-only

## Umbrella Charts

For multi-component applications, see `references/umbrella-charts.md`:

```yaml
# Chart.yaml
dependencies:
  - name: frontend
    version: "1.x.x"
    repository: "file://charts/frontend"
  - name: backend
    version: "2.0.0"
    repository: "https://charts.example.com"
    condition: backend.enabled
```

```bash
helm dependency update ./myapp
```

## References

| File | Content |
|------|---------|
| `references/values-patterns.md` | Industry-standard values.yaml patterns (Bitnami, ArgoCD, Grafana) |
| `references/functions.md` | Go/Sprig/Helm function reference |
| `references/common-pitfalls.md` | Template debugging patterns |
| `references/validation.md` | Full validation pipeline (ct, kubeconform, trivy, pluto) |
| `references/umbrella-charts.md` | Dependency management, multi-chart patterns |
