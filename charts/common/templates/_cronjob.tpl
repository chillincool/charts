{{/*
Common CronJob template for scheduled tasks
*/}}
{{- define "common.cronjob" -}}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  schedule: {{ .Values.schedule | quote }}
  concurrencyPolicy: {{ .Values.concurrencyPolicy | default "Forbid" }}
  successfulJobsHistoryLimit: {{ .Values.successfulJobsHistoryLimit | default 3 }}
  failedJobsHistoryLimit: {{ .Values.failedJobsHistoryLimit | default 1 }}
  {{- with .Values.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ . }}
  {{- end }}
  jobTemplate:
    spec:
      {{- with .Values.backoffLimit }}
      backoffLimit: {{ . }}
      {{- end }}
      template:
        metadata:
          {{- with .Values.podAnnotations }}
          annotations:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          labels:
            {{- include "common.selectorLabels" . | nindent 12 }}
        spec:
          {{- with .Values.imagePullSecrets }}
          imagePullSecrets:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          serviceAccountName: {{ include "common.serviceAccountName" . }}
          securityContext:
            {{- include "common.podSecurityContext" . | nindent 12 }}
          restartPolicy: {{ .Values.restartPolicy | default "Never" }}
          {{- with .Values.initContainers }}
          initContainers:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          containers:
            - name: {{ .Chart.Name }}
              securityContext:
                {{- include "common.securityContext" . | nindent 16 }}
              image: {{ include "common.image" . }}
              imagePullPolicy: {{ include "common.imagePullPolicy" . }}
              {{- with .Values.command }}
              command:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              {{- with .Values.args }}
              args:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              resources:
                {{- include "common.resources" . | nindent 16 }}
              {{- with .Values.env }}
              env:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              {{- if or .Values.persistence .Values.volumeMounts }}
              volumeMounts:
                {{- include "common.volumeMounts" . | nindent 16 }}
              {{- end }}
          {{- if or .Values.persistence .Values.volumes }}
          volumes:
            {{- include "common.volumes" . | nindent 12 }}
          {{- end }}
          {{- with .Values.nodeSelector }}
          nodeSelector:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.affinity }}
          affinity:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.tolerations }}
          tolerations:
            {{- toYaml . | nindent 12 }}
          {{- end }}
{{- end -}}
