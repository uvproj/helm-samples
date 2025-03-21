{{- define "libchart.configmap.tpl" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name | printf "%s-%s" .Chart.Name }}
data: {}
{{- end -}}
{{- define "libchart.configmap" -}}
{{- include "libchart.util.merge" (append . "libchart.configmap.tpl") -}}
{{- end -}}