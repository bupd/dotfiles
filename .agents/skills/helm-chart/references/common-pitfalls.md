# Helm Chart Common Pitfalls

## Whitespace Issues

### Problem: Unwanted blank lines

```yaml
# BAD - produces blank lines
data:
  {{ if .Values.key }}
  key: value
  {{ end }}

# GOOD - use {{- to chomp
data:
  {{- if .Values.key }}
  key: value
  {{- end }}
```

### Problem: Chomped too much

```yaml
# BAD - produces "key:value" (no space)
key: {{- .Values.name }}

# GOOD - chomp on the right side only, or add space
key: {{ .Values.name -}}
key:{{ " " }}{{- .Values.name }}
```

### Problem: Indentation in conditionals

```yaml
# BAD - mug is wrongly indented
data:
  myvalue: "Hello"
  {{ if .Values.coffee }}
    mug: "true"  # Wrong: extra indentation from template
  {{ end }}

# GOOD - align with output, not template structure
data:
  myvalue: "Hello"
  {{- if .Values.coffee }}
  mug: "true"
  {{- end }}
```

## Type Coercion

### Problem: Numbers become floats or scientific notation

```yaml
# values.yaml
port: 8080
bigNumber: 12345678

# BAD - may render as 1.2345678e+07
value: {{ .Values.bigNumber }}

# GOOD - explicit conversion or quote
value: {{ int .Values.bigNumber }}
value: {{ .Values.bigNumber | quote }}
```

### Problem: Boolean vs string "false"

```yaml
# values.yaml
enabled: false     # boolean
enabled: "false"   # string (not the same!)

# Template check
{{- if .Values.enabled }}  # "false" string is TRUTHY!
```

### Problem: Nil vs empty string

```yaml
# If value is not set at all (nil) vs empty string ""
{{- if .Values.name }}        # Both nil and "" are falsy
{{- if eq .Values.name "" }}  # Only matches ""
{{- if not .Values.name }}    # Matches nil, "", 0, false
```

## Nested Value Access

### Problem: Nil pointer dereference

```yaml
# values.yaml has no 'server' key

# BAD - panics if .Values.server is nil
name: {{ .Values.server.name }}

# GOOD - check each level
{{- if .Values.server }}
name: {{ .Values.server.name }}
{{- end }}

# OR use with
{{- with .Values.server }}
name: {{ .name }}
{{- end }}

# OR use dig (Sprig)
name: {{ dig "server" "name" "default" .Values }}
```

## Scope Issues

### Problem: Can't access parent in with/range

```yaml
# BAD - .Release not available inside with
{{- with .Values.config }}
release: {{ .Release.Name }}  # ERROR
{{- end }}

# GOOD - use $ for root scope
{{- with .Values.config }}
release: {{ $.Release.Name }}
{{- end }}

# OR capture in variable first
{{- $releaseName := .Release.Name -}}
{{- with .Values.config }}
release: {{ $releaseName }}
{{- end }}
```

## Label Selector Immutability

### Problem: Deployment selector can't be updated

```yaml
# BAD - includes mutable labels in selector
spec:
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
      version: {{ .Chart.Version }}  # Changes on upgrade!

# GOOD - only stable labels in selector
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "mychart.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
```

## Comment Issues

### Problem: YAML comments render in output

```yaml
# This comment appears in rendered YAML
key: value

# If using required, YAML comment causes error
# memory setting:
memory: {{ required "memory required" .Values.memory }}
```

### Solution: Use template comments for internal notes

```yaml
{{/* This comment is stripped from output */}}
key: value

{{- /*
Multi-line template comment
Also stripped from output
*/ -}}
```

## Quote Issues

### Problem: Unquoted values break YAML

```yaml
# values.yaml
message: "Hello: World"  # Contains colon

# BAD - breaks YAML parsing
message: {{ .Values.message }}
# Renders as: message: Hello: World  (invalid YAML)

# GOOD - always quote strings
message: {{ .Values.message | quote }}
# Renders as: message: "Hello: World"
```

### Problem: Quote vs squote in annotations

```yaml
# BAD - double quotes may conflict with JSON inside
annotations:
  config: {{ .Values.jsonConfig | quote }}

# GOOD - use toJson for JSON values
annotations:
  config: {{ .Values.config | toJson | quote }}
```

## include vs template

### Problem: template output can't be piped

```yaml
# BAD - template can't be indented
labels:
  {{ template "mychart.labels" . }}

# GOOD - include returns string, can be piped
labels:
  {{- include "mychart.labels" . | nindent 4 }}
```

## Range Empty List

### Problem: Range produces no output

```yaml
# If .Values.hosts is empty or nil
{{- range .Values.hosts }}
- {{ . }}
{{- end }}
# Produces nothing - may break parent structure

# GOOD - use range/else
{{- range .Values.hosts }}
- {{ . }}
{{- else }}
- "default.local"
{{- end }}
```

## toYaml Indentation

### Problem: Wrong indentation with toYaml

```yaml
# BAD - first line not indented
resources:
  {{ toYaml .Values.resources }}

# GOOD - use nindent (adds newline + indent)
resources:
  {{- toYaml .Values.resources | nindent 2 }}

# Or for inline (rare)
resources: {{ toYaml .Values.resources | indent 2 | trim }}
```

## lookup in Dry Run

### Problem: lookup returns empty in template mode

```yaml
# Works in real install, empty in helm template
{{- $secret := lookup "v1" "Secret" .Release.Namespace "my-secret" }}
{{- if $secret }}
# This block never executes during helm template
{{- end }}

# GOOD - handle both cases
{{- $secret := lookup "v1" "Secret" .Release.Namespace "my-secret" }}
{{- if $secret.data }}
existingKey: {{ index $secret.data "key" | b64dec }}
{{- else }}
# Generate or use default
newKey: {{ randAlphaNum 32 | b64enc }}
{{- end }}
```

## Name Length Limits

### Problem: Names exceed Kubernetes limits

```yaml
# Kubernetes DNS names limited to 63 chars
# Release names can be long: my-very-long-release-name-for-testing

# BAD - may exceed limit
name: {{ .Release.Name }}-{{ .Chart.Name }}-configmap

# GOOD - truncate
name: {{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}

# BEST - use helper
name: {{ include "mychart.fullname" . }}
```

## default Function Gotcha

### Problem: default doesn't work with false/0

```yaml
# default only triggers on nil/empty
{{ default true .Values.enabled }}  # If enabled: false, returns false not true

# For boolean defaults, be explicit
{{- if hasKey .Values "enabled" }}
enabled: {{ .Values.enabled }}
{{- else }}
enabled: true
{{- end }}

# Or use coalesce for first non-nil
{{ coalesce .Values.primary .Values.secondary "fallback" }}
```

## Chart.yaml appVersion

### Problem: appVersion not quoted breaks image tags

```yaml
# Chart.yaml
appVersion: 1.16.0  # Parsed as number!

# Template
image: nginx:{{ .Chart.AppVersion }}
# May render as: nginx:1.16 (loses .0)

# GOOD - quote in Chart.yaml
appVersion: "1.16.0"
```

## Multiline Strings

### Problem: Multiline values break YAML structure

```yaml
# values.yaml
config: |
  line1
  line2

# BAD - indentation lost
data:
  config: {{ .Values.config }}

# GOOD - preserve with proper quoting
data:
  config: |
    {{- .Values.config | nindent 4 }}

# Or use toYaml for complex structures
data:
  {{- toYaml .Values.config | nindent 2 }}
```

## Hook Annotations

### Problem: Hooks not in annotations block

```yaml
# BAD - hook at wrong level
metadata:
  name: my-job
  "helm.sh/hook": post-install  # Not an annotation!

# GOOD
metadata:
  name: my-job
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-delete-policy": hook-succeeded
```

## CRD Timing

### Problem: CRD not available when CR is created

```yaml
# CRDs in crds/ dir are installed first, but may not be ready
# Resources using CRD may fail on first install

# Solution 1: Put CRD in separate chart, install first
# Solution 2: Use helm.sh/hook: crd-install (deprecated in Helm 3)
# Solution 3: Wait/retry logic in application
```

## Secret Base64

### Problem: Double-encoding secrets

```yaml
# values.yaml
password: mypassword  # Plain text

# BAD - if value already base64
data:
  password: {{ .Values.password | b64enc }}

# GOOD - check if needs encoding
stringData:  # Kubernetes handles encoding
  password: {{ .Values.password }}

# Or for data: field
data:
  password: {{ .Values.password | b64enc }}
```
