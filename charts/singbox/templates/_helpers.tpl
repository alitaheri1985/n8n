{{/* Generate singbox chart name */}}
{{- define "singbox.name" -}}
singbox
{{- end }}

{{/* Generate full name */}}
{{- define "singbox.fullname" -}}
{{ printf "%s-%s" .Release.Name (include "singbox.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Labels */}}
{{- define "singbox.labels" -}}
app.kubernetes.io/name: {{ include "singbox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

