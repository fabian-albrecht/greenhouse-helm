{{/*
SPDX-FileCopyrightText: 2026 SAP SE or an SAP affiliate company and Greenhouse contributors
SPDX-License-Identifier: Apache-2.0
*/}}

{{- define "gateway-discovery-server.hostname" -}}
{{- if .Values.hostname -}}
{{ .Values.hostname }}
{{- else -}}
ghapi.{{ required "global.dnsDomain is required" .Values.global.dnsDomain }}
{{- end -}}
{{- end }}
