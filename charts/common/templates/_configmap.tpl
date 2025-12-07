{{/*
Common ConfigMap template
Renders a ConfigMap from .Values.configMap
*/}}
{{- define "common.configmap" -}}
{{- if .Values.configMap }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}-config
  labels:
    {{- include "common.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.configMap }}
  {{ $key }}: |
    {{- $value | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
