{{/*
Create job spec.
*/}}
{{- define "job.spec" -}}
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
{{ include "hmcts.podtemplate.v2.tpl" . | indent 2 -}}
{{- end -}}