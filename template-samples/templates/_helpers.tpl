{{/* Generate basic labels */}}
{{- define "mychart.labels" }}
  labels:
    generator: helm
    date: {{ now | htmlDate }}
    chart: {{ .Chart.Name }}
    version: {{ .Chart.Version }}
{{- end }}

{{/* Generate app name and version */}}
{{- define "mychart.app" -}}
app_name: {{ .Chart.Name }}
app_version: {{ .Chart.Version }}
{{- end -}}