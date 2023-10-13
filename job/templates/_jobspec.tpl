{{/*
Create job spec.
*/}}
{{- define "job.spec.v1" -}}
{{- $languageValues := deepCopy .Values}}
{{- if hasKey .Values "language" -}}
{{- $languageValues = (deepCopy .Values | merge (pluck .Values.language .Values | first) )}}
{{- end -}}
spec:
  {{- if $languageValues.backoffLimit }}
  backoffLimit: {{ $languageValues.backoffLimit }}
  {{- end }}
  {{- if $languageValues.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ $languageValues.activeDeadlineSeconds }}
  {{- end }}
  {{- if $languageValues.ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ $languageValues.ttlSecondsAfterFinished }}
  {{- end }}
  {{- if $languageValues.nodeSelector }}
  nodeSelector:
{{ toYaml $languageValues.nodeSelector | indent 4 }}
  {{- end }}
  {{- if $languageValues.tolerations }}
  tolerations:
{{ toYaml $languageValues.tolerations | indent 4 }}
  {{- end }}
{{ include "hmcts.podtemplate.v4.tpl" . | indent 2 -}}
{{- end -}}
