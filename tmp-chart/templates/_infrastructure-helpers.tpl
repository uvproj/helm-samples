{{- /* 
Define the names of various Azure resources based on the conventions of the ASO helm library.

NOTE: Some of these templates are independently defined in the sds-operator chart and they have
      to stay the same to avoid problems in the sds chart where both versions are present.
*/}}

{{- define "sds.resourceGroupName" -}}
{{- $nameOverride := "" }}
{{- if and (or (eq .Values.deploymentMode "local") (eq .Values.deploymentMode "devonebox")) .Values.localOverrides .Values.localOverrides.resourceGroupNames }}
{{- $nameOverride = get .Values.localOverrides.resourceGroupNames .type }}
{{- end }}
{{- if $nameOverride }}
{{- $nameOverride }}
{{- else }}
{{- printf "rg-%s-%s-sds" .Values.environment.environment .Values.region.regioncode }}
{{- end }}
{{- end }}

{{- define "sds.backupResourceGroupName" }}
{{- include "sds.resourceGroupName" (set $ "type" "backup") }}
{{- end }}

{{- define "sds.dataResourceGroupName" }}
{{- include "sds.resourceGroupName" (set $ "type" "data") }}
{{- end }}

{{- define "sds.storageAccountName" }}
{{- $generatedStorageAccountName := printf "%s%ssds%s" .Values.environment.environment .Values.geography.name .suffix }}
{{- printf "st%s" $generatedStorageAccountName | replace "-" "" | trunc 24 }}
{{- end }}


{{- define "common.isPrimaryRegion" -}}
{{ if eq .Values.environment.primaryGlobalLocation .Values.region.region }}true{{ else }}false{{ end }}
{{- end }}
