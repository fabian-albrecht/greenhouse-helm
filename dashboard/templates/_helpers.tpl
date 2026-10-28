{{/*
Resource name: avoids double "dashboard-dashboard" when the release name already
contains "dashboard". Falls back to "<release>-dashboard" otherwise.
*/}}
{{- define "dashboard.fullname" -}}
{{- if contains "dashboard" .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-dashboard" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* Render the dashboard hostname */}}
{{- define "dashboard.hostname" -}}
{{- printf "%s.%s" "dashboard" (required "global.dnsDomain missing" .Values.global.dnsDomain) }}
{{- end }}

{{/* Render the auth hostname */}}
{{- define "dashboard.auth.hostname" -}}
{{- printf "https://%s.%s" "auth" (required "global.dnsDomain missing" .Values.global.dnsDomain) }}
{{- end }}

{{/* Render the k8s api hostname */}}
{{- define "dashboard.api.hostname" -}}
{{- if .Values.apiserverHostname -}}
{{- printf "https://%s" .Values.apiserverHostname -}}
{{- else -}}
{{- printf "https://api.%s" (required "global.dnsDomain missing" .Values.global.dnsDomain) -}}
{{- end -}}
{{- end }}

{{/*
Print the image reference. Digest takes precedence over tag.
*/}}
{{- define "dashboard.image" -}}
{{- $repository := ( required ".Values.image.repository missing" .Values.image.repository ) -}}
{{- $digest := .Values.image.digest -}}
{{- if $digest -}}
  {{- printf "%s@%s" $repository $digest -}}
{{- else -}}
  {{- printf "%s:%s" $repository ( required ".Values.image.tag missing" .Values.image.tag ) -}}
{{- end -}}
{{- end -}}
