{{/*
Common defaults library - reusable snippets similar to YAML anchors
These can be included in any chart that depends on common
*/}}

{{/*
=============================================================================
SECURITY CONTEXTS
=============================================================================
*/}}

{{/*
Default security context for non-root containers
Usage: {{ include "common.defaultSecurityContext" . }}
*/}}
{{- define "common.defaultSecurityContext" -}}
seccompProfile:
  type: RuntimeDefault
readOnlyRootFilesystem: true
allowPrivilegeEscalation: false
runAsNonRoot: true
runAsUser: 568
runAsGroup: 568
capabilities:
  drop:
    - ALL
{{- end -}}

{{/*
Default pod security context
Usage: {{ include "common.defaultPodSecurityContext" . }}
*/}}
{{- define "common.defaultPodSecurityContext" -}}
seccompProfile:
  type: RuntimeDefault
runAsUser: 568
runAsGroup: 568
fsGroup: 568
fsGroupChangePolicy: "OnRootMismatch"
{{- end -}}

{{/*
Security context merged with values - allows override
Usage: {{ include "common.securityContext" . | nindent 12 }}
*/}}
{{- define "common.securityContext" -}}
{{- if .Values.securityContext -}}
{{- toYaml .Values.securityContext -}}
{{- else -}}
{{- include "common.defaultSecurityContext" . -}}
{{- end -}}
{{- end -}}

{{/*
Pod security context merged with values - allows override
Usage: {{ include "common.podSecurityContext" . | nindent 8 }}
*/}}
{{- define "common.podSecurityContext" -}}
{{- if .Values.podSecurityContext -}}
{{- toYaml .Values.podSecurityContext -}}
{{- else -}}
{{- include "common.defaultPodSecurityContext" . -}}
{{- end -}}
{{- end -}}

{{/*
=============================================================================
RESOURCE LIMITS
=============================================================================
*/}}

{{/*
Default resource limits for lightweight apps
Usage: {{ include "common.defaultResources" . }}
*/}}
{{- define "common.defaultResources" -}}
requests:
  cpu: 10m
  memory: 128Mi
limits:
  cpu: 1
  memory: 1Gi
{{- end -}}

{{/*
Resource limits for streaming/media apps (higher memory)
Usage: {{ include "common.streamingResources" . }}
*/}}
{{- define "common.streamingResources" -}}
requests:
  cpu: 100m
  memory: 512Mi
limits:
  cpu: 2
  memory: 4Gi
{{- end -}}

{{/*
Resource limits for download clients (bursty CPU)
Usage: {{ include "common.downloadResources" . }}
*/}}
{{- define "common.downloadResources" -}}
requests:
  cpu: 100m
  memory: 512Mi
limits:
  cpu: 500m
  memory: 2Gi
{{- end -}}

{{/*
Resources merged with values - allows override
Usage: {{ include "common.resources" . | nindent 12 }}
*/}}
{{- define "common.resources" -}}
{{- if .Values.resources -}}
{{- toYaml .Values.resources -}}
{{- else -}}
{{- include "common.defaultResources" . -}}
{{- end -}}
{{- end -}}

{{/*
=============================================================================
VOLUME MOUNTS - Common patterns
=============================================================================
*/}}

{{/*
Standard config volume mount
Usage: {{ include "common.configVolumeMount" . | nindent 12 }}
*/}}
{{- define "common.configVolumeMount" -}}
- name: config
  mountPath: /config
{{- end -}}

{{/*
Tmp volume mount (for readOnlyRootFilesystem)
Usage: {{ include "common.tmpVolumeMount" . | nindent 12 }}
*/}}
{{- define "common.tmpVolumeMount" -}}
- name: tmp
  mountPath: /tmp
{{- end -}}

{{/*
Media storage volume mount
Usage: {{ include "common.mediaVolumeMount" . | nindent 12 }}
*/}}
{{- define "common.mediaVolumeMount" -}}
- name: media
  mountPath: /media
{{- end -}}

{{/*
Downloads volume mount
Usage: {{ include "common.downloadsVolumeMount" . | nindent 12 }}
*/}}
{{- define "common.downloadsVolumeMount" -}}
- name: downloads
  mountPath: /downloads
{{- end -}}

{{/*
Standard *arr app volume mounts (config + media + downloads)
Usage: {{ include "common.arrVolumeMounts" . | nindent 12 }}
*/}}
{{- define "common.arrVolumeMounts" -}}
- name: config
  mountPath: /config
- name: media
  mountPath: /media
- name: downloads
  mountPath: /downloads
- name: tmp
  mountPath: /tmp
{{- end -}}

{{/*
=============================================================================
VOLUMES - Common patterns  
=============================================================================
*/}}

{{/*
Tmp emptyDir volume (for readOnlyRootFilesystem)
Usage: {{ include "common.tmpVolume" . | nindent 8 }}
*/}}
{{- define "common.tmpVolume" -}}
- name: tmp
  emptyDir:
    sizeLimit: 1Gi
{{- end -}}

{{/*
Config emptyDir volume (for dev/testing)
Usage: {{ include "common.configEmptyDirVolume" . | nindent 8 }}
*/}}
{{- define "common.configEmptyDirVolume" -}}
- name: config
  emptyDir: {}
{{- end -}}

{{/*
Config PVC volume template
Usage: {{ include "common.configPvcVolume" (dict "claimName" "my-config") | nindent 8 }}
*/}}
{{- define "common.configPvcVolume" -}}
- name: config
  persistentVolumeClaim:
    claimName: {{ .claimName }}
{{- end -}}

{{/*
=============================================================================
PROBES - Common patterns
=============================================================================
*/}}

{{/*
Default HTTP liveness probe
Usage: {{ include "common.defaultLivenessProbe" . }}
*/}}
{{- define "common.defaultLivenessProbe" -}}
httpGet:
  path: {{ ((.Values.probes).path) | default "/ping" }}
  port: http
initialDelaySeconds: 45
periodSeconds: 30
timeoutSeconds: 10
failureThreshold: 3
{{- end -}}

{{/*
Default HTTP readiness probe
Usage: {{ include "common.defaultReadinessProbe" . }}
*/}}
{{- define "common.defaultReadinessProbe" -}}
httpGet:
  path: {{ ((.Values.probes).path) | default "/ping" }}
  port: http
initialDelaySeconds: 15
periodSeconds: 10
timeoutSeconds: 5
failureThreshold: 3
{{- end -}}

{{/*
TCP liveness probe (for apps without HTTP health endpoints)
Usage: {{ include "common.tcpLivenessProbe" . }}
*/}}
{{- define "common.tcpLivenessProbe" -}}
tcpSocket:
  port: http
initialDelaySeconds: 30
periodSeconds: 30
timeoutSeconds: 5
failureThreshold: 3
{{- end -}}

{{/*
TCP readiness probe
Usage: {{ include "common.tcpReadinessProbe" . }}
*/}}
{{- define "common.tcpReadinessProbe" -}}
tcpSocket:
  port: http
initialDelaySeconds: 10
periodSeconds: 10
timeoutSeconds: 5
failureThreshold: 3
{{- end -}}

{{/*
Liveness probe merged with values - allows override
Usage: {{ include "common.livenessProbe" . | nindent 12 }}
*/}}
{{- define "common.livenessProbe" -}}
{{- if .Values.livenessProbe -}}
{{- toYaml .Values.livenessProbe -}}
{{- else -}}
{{- include "common.defaultLivenessProbe" . -}}
{{- end -}}
{{- end -}}

{{/*
Readiness probe merged with values - allows override
Usage: {{ include "common.readinessProbe" . | nindent 12 }}
*/}}
{{- define "common.readinessProbe" -}}
{{- if .Values.readinessProbe -}}
{{- toYaml .Values.readinessProbe -}}
{{- else -}}
{{- include "common.defaultReadinessProbe" . -}}
{{- end -}}
{{- end -}}

{{/*
=============================================================================
AFFINITY & SCHEDULING
=============================================================================
*/}}

{{/*
Anti-affinity to spread pods across nodes
Usage: {{ include "common.podAntiAffinity" . | nindent 8 }}
*/}}
{{- define "common.podAntiAffinity" -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            {{- include "common.selectorLabels" . | nindent 12 }}
        topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
=============================================================================
ENVIRONMENT VARIABLES - Common patterns
=============================================================================
*/}}

{{/*
Standard timezone env var
Usage: {{ include "common.tzEnv" . | nindent 12 }}
*/}}
{{- define "common.tzEnv" -}}
- name: TZ
  value: {{ .Values.timezone | default "UTC" }}
{{- end -}}

{{/*
Standard PUID/PGID env vars for linuxserver.io style containers
Usage: {{ include "common.linuxserverEnv" . | nindent 12 }}
*/}}
{{- define "common.linuxserverEnv" -}}
- name: PUID
  value: "568"
- name: PGID
  value: "568"
- name: TZ
  value: {{ .Values.timezone | default "UTC" }}
{{- end -}}

{{/*
=============================================================================
ANNOTATIONS - Common patterns
=============================================================================
*/}}

{{/*
Reloader annotations for ConfigMap changes
Usage: {{ include "common.reloaderAnnotations" (dict "configmaps" "app-config,app-secrets") | nindent 8 }}
*/}}
{{- define "common.reloaderAnnotations" -}}
configmap.reloader.stakater.com/reload: {{ .configmaps | quote }}
{{- end -}}
