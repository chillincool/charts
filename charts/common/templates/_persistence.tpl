{{/*
Persistence templates for volumes and volumeMounts
Supports the k8s-at-home persistence pattern
*/}}

{{/*
Generate volume mounts from persistence configuration
Usage: {{ include "common.volumeMounts" . | nindent 12 }}
*/}}
{{- define "common.volumeMounts" -}}
{{- range $name, $persistence := .Values.persistence -}}
{{- if $persistence.enabled -}}
{{- if $persistence.globalMounts -}}
{{- range $mount := $persistence.globalMounts }}
- name: {{ $name }}
  mountPath: {{ $mount.path }}
  {{- with $mount.subPath }}
  subPath: {{ . }}
  {{- end }}
  {{- with $mount.readOnly }}
  readOnly: {{ . }}
  {{- end }}
{{- end }}
{{- else }}
- name: {{ $name }}
  mountPath: {{ $persistence.mountPath | default (printf "/%s" $name) }}
  {{- with $persistence.subPath }}
  subPath: {{ . }}
  {{- end }}
  {{- with $persistence.readOnly }}
  readOnly: {{ . }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- /* Also include any manual volumeMounts from values */ -}}
{{- with .Values.volumeMounts }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
Generate volumes from persistence configuration
Usage: {{ include "common.volumes" . | nindent 8 }}
*/}}
{{- define "common.volumes" -}}
{{- range $name, $persistence := .Values.persistence -}}
{{- if $persistence.enabled }}
- name: {{ $name }}
  {{- $type := $persistence.type | default "pvc" }}
  {{- if or (eq $type "pvc") (eq $type "persistentVolumeClaim") }}
  {{- if $persistence.existingClaim }}
  persistentVolumeClaim:
    claimName: {{ $persistence.existingClaim }}
  {{- else }}
  persistentVolumeClaim:
    claimName: {{ include "common.fullname" $ }}-{{ $name }}
  {{- end }}
  {{- else if eq $type "emptyDir" }}
  emptyDir:
    {{- with $persistence.sizeLimit }}
    sizeLimit: {{ . }}
    {{- end }}
    {{- with $persistence.medium }}
    medium: {{ . }}
    {{- end }}
  {{- else if eq $type "configMap" }}
  configMap:
    name: {{ $persistence.configMapName | default (include "common.fullname" $) }}
    {{- with $persistence.defaultMode }}
    defaultMode: {{ . }}
    {{- end }}
    {{- with $persistence.items }}
    items:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- else if eq $type "secret" }}
  secret:
    secretName: {{ $persistence.secretName | default (include "common.fullname" $) }}
    {{- with $persistence.defaultMode }}
    defaultMode: {{ . }}
    {{- end }}
    {{- with $persistence.items }}
    items:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- else if eq $type "hostPath" }}
  hostPath:
    path: {{ required "hostPath.path is required" $persistence.hostPath }}
    {{- with $persistence.hostPathType }}
    type: {{ . }}
    {{- end }}
  {{- else if eq $type "custom" }}
  {{- toYaml $persistence.volumeSpec | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}
{{- /* Also include any manual volumes from values */ -}}
{{- with .Values.volumes }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
Generate PersistentVolumeClaim resources
Usage: {{ include "common.pvcs" . }}
*/}}
{{- define "common.pvcs" -}}
{{- range $name, $persistence := .Values.persistence -}}
{{- $type := $persistence.type | default "pvc" }}
{{- if and $persistence.enabled (or (eq $type "pvc") (eq $type "persistentVolumeClaim")) (not $persistence.existingClaim) }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.fullname" $ }}-{{ $name }}
  labels:
    {{- include "common.labels" $ | nindent 4 }}
spec:
  accessModes:
    - {{ $persistence.accessMode | default "ReadWriteOnce" }}
  {{- with $persistence.storageClass }}
  storageClassName: {{ . }}
  {{- end }}
  resources:
    requests:
      storage: {{ $persistence.size | default "1Gi" }}
{{- end }}
{{- end }}
{{- end -}}
