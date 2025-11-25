{{/*
Common ConfigMap template
*/}}
{{- define "common.configmap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
{{- end -}}

{{/*
Common Secret template
*/}}
{{- define "common.secret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
type: {{ .Values.secret.type | default "Opaque" }}
{{- end -}}

{{/*
Common Service template
*/}}
{{- define "common.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type | default "ClusterIP" }}
  ports:
    - port: {{ .Values.service.port | default 80 }}
      targetPort: {{ .Values.service.targetPort | default "http" }}
      protocol: TCP
      name: http
  selector:
    {{- include "common.selectorLabels" . | nindent 4 }}
{{- end -}}

{{/*
Common ServiceAccount template
*/}}
{{- define "common.serviceaccount" -}}
{{- if .Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "common.serviceAccountName" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
Common Ingress template
*/}}
{{- define "common.ingress" -}}
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "ImplementationSpecific" }}
            backend:
              service:
                name: {{ include "common.fullname" $ }}
                port:
                  number: {{ $.Values.service.port | default 80 }}
          {{- end }}
    {{- end }}
{{- end -}}
{{- end -}}
