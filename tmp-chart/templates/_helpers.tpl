{{- define "imageWithRegistry" -}}
{{- $registryServer := index . 0 -}}
{{- $imageName := index . 1 -}}
{{- if ne $registryServer "" -}}
{{- printf "%s/%s" $registryServer $imageName -}}
{{- else -}}
{{ printf "%s" $imageName }}
{{- end -}}
{{- end -}}

{{- define "sdsImage" }}
image: "{{ include "imageWithRegistry" (list .global.Values.environment.containerRegistryServer .imageName) }}:{{ .global.Values.buildVariables.tag }}"
imagePullPolicy: "{{ .global.Values.imagePolicy }}"
{{- end }}