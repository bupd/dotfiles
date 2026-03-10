# values.yaml Patterns

Industry-standard patterns from Bitnami, Grafana, ArgoCD, and official Helm charts.

## Core Principles

1. **Subtrees for complex objects** - Use nested structures for K8s API objects that users will `toYaml`
2. **Empty defaults `{}`** - Let users override entire sections, show examples in comments
3. **Flat for simple values** - Single values like `replicaCount` stay top-level
4. **Consistent naming** - camelCase throughout, match K8s API field names

---

## Image Configuration

**Always use subtree** - allows registry, repository, tag, and policy to be set independently:

```yaml
image:
  registry: docker.io
  repository: nginx
  tag: ""                    # Defaults to Chart.appVersion
  # digest: ""               # Overrides tag if set
  pullPolicy: IfNotPresent

imagePullSecrets: []
# - name: regcred
```

**Template usage:**
```yaml
image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
imagePullPolicy: {{ .Values.image.pullPolicy }}
```

---

## Resources

**Empty default with commented examples** - production users will set their own:

```yaml
resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi
```

**Template usage:**
```yaml
resources:
  {{- toYaml .Values.resources | nindent 12 }}
```

**Alternative: Bitnami style with resourcesPreset:**
```yaml
resourcesPreset: "small"   # none, nano, micro, small, medium, large, xlarge, 2xlarge
resources: {}              # Overrides preset if set
```

---

## Security Contexts

### Simple Style (helm create default)

Empty objects, users provide full context:

```yaml
podSecurityContext: {}
  # fsGroup: 2000

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000
```

### Bitnami Style (Production)

Enabled flag + explicit fields for OpenShift compatibility:

```yaml
podSecurityContext:
  enabled: true
  fsGroupChangePolicy: Always
  sysctls: []
  supplementalGroups: []
  fsGroup: 1001

containerSecurityContext:
  enabled: true
  seLinuxOptions: {}
  runAsUser: 1001
  runAsGroup: 1001
  runAsNonRoot: true
  privileged: false
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: RuntimeDefault
```

**Template (Bitnami style):**
```yaml
{{- if .Values.podSecurityContext.enabled }}
securityContext: {{- omit .Values.podSecurityContext "enabled" | toYaml | nindent 8 }}
{{- end }}
```

---

## Service

```yaml
service:
  type: ClusterIP
  port: 80
  # nodePort: 30080        # Only for NodePort/LoadBalancer
  # clusterIP: ""          # Set to None for headless
  # loadBalancerIP: ""
  # loadBalancerSourceRanges: []
  # externalTrafficPolicy: Cluster
  annotations: {}
  labels: {}
```

---

## Ingress

```yaml
ingress:
  enabled: false
  className: ""             # nginx, traefik, etc.
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # cert-manager.io/cluster-issuer: letsencrypt
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []
  # - secretName: chart-example-tls
  #   hosts:
  #     - chart-example.local
```

---

## ServiceAccount

```yaml
serviceAccount:
  create: true
  automount: true
  annotations: {}
  name: ""                  # Defaults to fullname if create=true
```

---

## Autoscaling (HPA)

```yaml
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80
  # behavior: {}
```

**Template:**
```yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
# ...
{{- end }}
```

---

## Probes

### Simple Style

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: http
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 1
  failureThreshold: 3
  successThreshold: 1

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10
```

### Flexible Style (Bitnami)

Allow users to define custom probe or use defaults:

```yaml
livenessProbe:
  enabled: true
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 1
  failureThreshold: 3
  successThreshold: 1

customLivenessProbe: {}
# httpGet:
#   path: /custom
#   port: http
```

---

## Persistence

```yaml
persistence:
  enabled: false
  storageClass: ""          # "" = default, "-" = no class
  accessModes:
    - ReadWriteOnce
  size: 8Gi
  annotations: {}
  # existingClaim: ""       # Use existing PVC
  # selector: {}
```

---

## RBAC

```yaml
rbac:
  create: true
  rules: []
  # - apiGroups: [""]
  #   resources: ["pods"]
  #   verbs: ["get", "list", "watch"]

serviceAccount:
  create: true
  name: ""
```

---

## Scheduling

```yaml
nodeSelector: {}

tolerations: []
# - key: "key"
#   operator: "Equal"
#   value: "value"
#   effect: "NoSchedule"

affinity: {}
# nodeAffinity:
#   requiredDuringSchedulingIgnoredDuringExecution:
#     nodeSelectorTerms: [...]

topologySpreadConstraints: []
```

---

## Pod Configuration

```yaml
replicaCount: 1

podAnnotations: {}
podLabels: {}

# Update strategy
updateStrategy:
  type: RollingUpdate
  # rollingUpdate:
  #   maxUnavailable: 1
  #   maxSurge: 1

# Lifecycle
terminationGracePeriodSeconds: 30

# Priority
priorityClassName: ""

# DNS
dnsPolicy: ClusterFirst
dnsConfig: {}

# Host settings
hostNetwork: false
hostPID: false
hostIPC: false
```

---

## Environment Variables

```yaml
# Direct env vars
env: []
# - name: FOO
#   value: "bar"
# - name: SECRET
#   valueFrom:
#     secretKeyRef:
#       name: mysecret
#       key: password

# From ConfigMaps/Secrets
envFrom: []
# - configMapRef:
#     name: config-map-name
# - secretRef:
#     name: secret-name
```

---

## Extra/Custom Resources

Allow injection of arbitrary content:

```yaml
# Extra volumes
extraVolumes: []
# - name: extra-volume
#   configMap:
#     name: my-config

extraVolumeMounts: []
# - name: extra-volume
#   mountPath: /etc/extra

# Extra containers (sidecars)
extraContainers: []

# Extra init containers
extraInitContainers: []

# Extra env vars
extraEnvVars: []
```

---

## Metrics/Monitoring

```yaml
metrics:
  enabled: false
  
  service:
    port: 9090
    annotations: {}
  
  serviceMonitor:
    enabled: false
    namespace: ""
    interval: 30s
    scrapeTimeout: 10s
    labels: {}
    selector: {}
    relabelings: []
    metricRelabelings: []

  prometheusRule:
    enabled: false
    namespace: ""
    rules: []
```

---

## Complete Example

```yaml
# Deployment settings
replicaCount: 1
revisionHistoryLimit: 3

# Image
image:
  registry: docker.io
  repository: nginx
  tag: ""
  pullPolicy: IfNotPresent

imagePullSecrets: []

# Naming
nameOverride: ""
fullnameOverride: ""

# Service Account
serviceAccount:
  create: true
  automount: true
  annotations: {}
  name: ""

# Pod settings
podAnnotations: {}
podLabels: {}

podSecurityContext: {}
  # fsGroup: 2000

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

# Service
service:
  type: ClusterIP
  port: 80

# Ingress
ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

# Resources
resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

# Probes
livenessProbe:
  httpGet:
    path: /
    port: http
readinessProbe:
  httpGet:
    path: /
    port: http

# Autoscaling
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

# Scheduling
nodeSelector: {}
tolerations: []
affinity: {}
```

---

## Anti-Patterns

### DON'T: Flat structure for complex objects

```yaml
# Bad - hard to override, loses structure
resourceLimitsCpu: 100m
resourceLimitsMemory: 128Mi
resourceRequestsCpu: 50m
```

### DON'T: Hardcoded values users can't disable

```yaml
# Bad - users can't remove securityContext
securityContext:
  runAsNonRoot: true   # No way to disable
```

### DON'T: Inconsistent nesting

```yaml
# Bad - mixing patterns
image: nginx:latest          # Flat
service:                     # Nested
  port: 80
ingressEnabled: false        # Flat again
```

### DO: Consistent, overridable structure

```yaml
# Good - consistent nesting, empty defaults
image:
  repository: nginx
  tag: latest
service:
  port: 80
ingress:
  enabled: false
securityContext: {}          # User provides if needed
```
