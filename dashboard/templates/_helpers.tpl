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
{{- printf "%s.%s" .Values.subDomain (required "global.dnsDomain missing" .Values.global.dnsDomain) }}
{{- end }}

{{/* Render the auth hostname */}}
{{- define "dashboard.auth.hostname" -}}
{{- printf "https://%s.%s" .Values.authSubDomain (required "global.dnsDomain missing" .Values.global.dnsDomain) }}
{{- end }}

{{/* Render the k8s api hostname */}}
{{- define "dashboard.api.hostname" -}}
{{- printf "https://%s.%s" .Values.corsProxySubDomain (required "global.dnsDomain missing" .Values.global.dnsDomain) -}}
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

{{/* ----------------------------------------------------------------------- */}}
{{/* cors-proxy helpers                                                       */}}
{{/* Merged in from the former cors-proxy subchart. These read the           */}}
{{/* .Values.corsProxy.* subtree and derive names from the literal           */}}
{{/* "cors-proxy" (NOT .Chart.Name) so resource names/labels stay exactly    */}}
{{/* <release>-cors-proxy / app.kubernetes.io/name: cors-proxy.              */}}
{{/* ----------------------------------------------------------------------- */}}

{{/*
Validate that ingress and gateway are not both enabled.
*/}}
{{- define "cors-proxy.validateExposure" -}}
{{- if and .Values.corsProxy.ingress.enabled .Values.corsProxy.gateway.enabled -}}
{{- fail "corsProxy.ingress.enabled and corsProxy.gateway.enabled are mutually exclusive — disable one of them" -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the cors-proxy. Fixed to the literal chart-of-origin name so
resource names are stable regardless of the (now dashboard) .Chart.Name.
*/}}
{{- define "cors-proxy.name" -}}
{{- default "cors-proxy" .Values.corsProxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified cors-proxy name (<release>-cors-proxy).
If the release name already contains the name it is used as-is.
*/}}
{{- define "cors-proxy.fullname" -}}
{{- if .Values.corsProxy.fullnameOverride }}
{{- .Values.corsProxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "cors-proxy" .Values.corsProxy.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart label for cors-proxy resources. Uses the (now dashboard) chart name+version.
This is a metadata label only — not part of any selector — so sharing the
dashboard chart version here is safe.
*/}}
{{- define "cors-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Print the cors-proxy image reference. Digest takes precedence over tag.
Tag is pinned in values (corsProxy.image.tag) rather than following .Chart.AppVersion.
*/}}
{{- define "cors-proxy.image" -}}
{{- $repository := .Values.corsProxy.image.repository -}}
{{- $digest := .Values.corsProxy.image.digest -}}
{{- if $digest -}}
  {{- printf "%s@%s" $repository $digest -}}
{{- else -}}
  {{- printf "%s:%s" $repository (.Values.corsProxy.image.tag | default .Chart.AppVersion) -}}
{{- end -}}
{{- end -}}

{{/*
Common labels for cors-proxy resources.
*/}}
{{- define "cors-proxy.labels" -}}
helm.sh/chart: {{ include "cors-proxy.chart" . }}
{{ include "cors-proxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for cors-proxy resources. MUST stay stable (used in Deployment
and Service selectors) — name is the literal "cors-proxy".
*/}}
{{- define "cors-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cors-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the cors-proxy service account to use.
*/}}
{{- define "cors-proxy.serviceAccountName" -}}
{{- if .Values.corsProxy.serviceAccount.create }}
{{- default (include "cors-proxy.fullname" .) .Values.corsProxy.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.corsProxy.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Render the cors-proxy exposed hostname. Sourced from the dashboard's
corsProxySubDomain (single source of truth with dashboard.api.hostname) so the
proxy's host and the appProps apiEndpoint cannot drift across exposure modes.
*/}}
{{- define "cors-proxy.api.hostname" -}}
{{- printf "%s.%s" .Values.corsProxySubDomain (required "global.dnsDomain missing" .Values.global.dnsDomain) -}}
{{- end }}
