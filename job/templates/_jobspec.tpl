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
  template:
    spec:
      {{- if $languageValues.operator.nodeSelector }}
      nodeSelector:
      {{ toYaml $languageValues.operator.nodeSelector | indent 8 }}
      {{- end }}
      {{- if $languageValues.operator.tolerations }}
      tolerations:
      {{ toYaml $languageValues.operator.tolerations | indent 8 }}
      {{- end }}
{{ include "hmcts.podtemplate.v4.tpl" . | indent 2 -}}
{{- end -}}
