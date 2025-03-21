{{- /*
Refer: https://azure.github.io/azure-service-operator/reference/insights/v1api20180301/#insights.azure.com/v1api20180301.MetricAlert
*/ -}}
{{- define "custom.aso2.metricAlert" }}
apiVersion: insights.azure.com/v1api20180301
kind: MetricAlert
metadata:
  name: {{ .name }}
  annotations: 
  {{ .annotations | toYaml | indent 2 }}
spec:
  criteria:
    microsoftAzureMonitorSingleResourceMultipleMetricCriteria:
      allOf:
      - criterionType: StaticThresholdCriterion
        metricName: {{ .criteria.metricName }}
        metricNamespace: {{ .criteria.metricNamespace }}
        name: {{ .name | quote }}
        operator: {{ .criteria.operator }}
        skipMetricValidation: true
        threshold: {{ .criteria.threshold }}
        timeAggregation: {{ .criteria.timeAggregation }}
        {{- if .criteria.dimensions }}
        dimensions:
        {{- range $dimension := .criteria.dimensions }}
        - name: {{ $dimension.name }}
          operator: {{$dimension.operator }}
          values:
          {{- range $value := $dimension.values }}
          - {{ $value }}
          {{- end -}}
        {{- end -}}
        {{- end }}
      odata.type: Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria
  actions:
  - actionGroupId: {{ .global.Values.geography.monitoringActionGroupId }}
  {{- if .actionGroupId }}
  - actionGroupId: {{ .actionGroupId }}
  {{- end }}
  enabled: true
  evaluationFrequency: {{ .evaluationFrequency }}
  location: global
  owner:
    name: {{ .owner.name }}
  scopesReferences:
  {{- if .scopeReference.armId }}
  - armId: {{ .scopeReference.armId }}
  {{- else }}
  - group: {{ .scopeReference.group }}
    kind: {{ .scopeReference.kind }}
    name: {{ .scopeReference.name }}
  {{- end }}
  severity: {{ .severity }}
  windowSize: {{ .windowSize }}
  autoMitigate: true
  description: {{ .description }}
{{- if .global }}
  tags:
{{ include "common.tags" .global | indent 4 }}
{{- end }}
---
{{- end }}