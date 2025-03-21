{{- /* 
Azure SA Scalability and Performance Targets: https://learn.microsoft.com/en-us/azure/storage/common/scalability-targets-standard-account
Alert Severity numbers correspond to 
    0-Critical, 
    1-Error, 
    2-Warning, 
    3-Informational
    4-Verbose
Note: This file is duplicated in sds-instance-internal chart as well. Please keep both files in sync
*/ -}}
{{- define "sds.alerts.storageAlerts" }}
{{- $scopeReference := dict
    "group" "storage.azure.com"
    "kind" "StorageAccount"
    "name" .storageAccountName
-}}
{{- $owner := dict
    "name" .resourceGroupName
-}}
{{- $annotations := dict
    "serviceoperator.azure.com/reconcile-policy" "none"
-}}
{{- /* 
Storage Account Capacity Limit: 5 PiB
Setting 4 PiB (80%) threshold for Storage Account capacity criteria 
Setting 1 hour window size (minimum when creating alert with UsedCapacity in browser) */ -}}
{{- $capacityCriteria := dict 
    "metricName" "UsedCapacity"
    "metricNamespace" "microsoft.storage/storageaccounts"
    "operator" "GreaterThan"
    "threshold" (4 | mulf 1048576 | mulf 1048576 | mulf 1024)
    "timeAggregation" "Average"
-}}
{{- $storageAccountCapacityAlert := dict 
    "global" .global
    "name" (printf "usedcapacity-nearinglimit-%s" .storageAccountName)
    "annotations" $annotations
    "criteria" $capacityCriteria
    "evaluationFrequency" "PT5M"
    "owner" $owner
    "scopeReference" $scopeReference
    "severity" 2 
    "windowSize" "PT1H"
    "description" (printf "Storage account '%s' approaching capacity limit (Crossed 4 PiB)." .storageAccountName | quote)
-}}
{{- /* Setting 99.9 percent threshold for Storage Account availability criteria */ -}}
{{- $availabilityCriteria := dict 
    "metricName" "Availability"
    "metricNamespace" "microsoft.storage/storageaccounts"
    "operator" "LessThan"
    "threshold" 99.9
    "timeAggregation" "Average"
-}}
{{- $storageAccountAvailabilityAlert := dict 
    "global" .global
    "name" (printf "availability-lessthanthreshold-%s" .storageAccountName)
    "annotations" $annotations
    "criteria" $availabilityCriteria
    "evaluationFrequency" "PT1M"
    "owner" $owner
    "scopeReference" $scopeReference
    "severity" 2 
    "windowSize" "PT5M"
    "description" (printf "Storage account '%s' availability less than threshold." .storageAccountName | quote)
-}}
{{- /* 
Storage Account v1 Ingress Limit: 10 Gbps
Setting alert criteria to 8 Gbps (1 GBps) (80%) 
Aggregating as total for 5 minute window size */ -}}
{{- $ingressCriteria := dict 
    "metricName" "Ingress"
    "metricNamespace" "microsoft.storage/storageaccounts"
    "operator" "GreaterThan"
    "threshold" (8 | divf 8 | mulf 300 | mulf 1000000000)
    "timeAggregation" "Total"
-}}
{{- $storageAccountIngressAlert := dict 
    "global" .global
    "name" (printf "ingress-morethanthreshold-%s" .storageAccountName)
    "annotations" $annotations
    "criteria" $ingressCriteria
    "evaluationFrequency" "PT1M"
    "owner" $owner
    "scopeReference" $scopeReference
    "severity" 2 
    "windowSize" "PT5M"
    "description" (printf "Storage account '%s' ingress more than threshold." .storageAccountName | quote)
-}}
{{- /* 
Storage Account v1 Egress Limit: 10 Gbps (20 Gbps for US regions)
Setting alert criteria to 8 Gbps (1 GBps) (80% of lower limit among all regions). 
Aggregating as total for 5 minute window size */ -}}
{{- $egressCriteria := dict 
    "metricName" "Egress"
    "metricNamespace" "microsoft.storage/storageaccounts"
    "operator" "GreaterThan"
    "threshold" (8 | divf 8 | mulf 300 | mulf 1000000000)
    "timeAggregation" "Total"
-}}
{{- $storageAccountEgressAlert := dict 
    "global" .global
    "name" (printf "egress-morethanthreshold-%s" .storageAccountName)
    "annotations" $annotations
    "criteria" $egressCriteria
    "evaluationFrequency" "PT1M"
    "owner" $owner
    "scopeReference" $scopeReference
    "severity" 2 
    "windowSize" "PT5M"
    "description" (printf "Storage account '%s' egress more than threshold." .storageAccountName | quote)
-}}
{{- /* 
Storage Account request limit: 20000 requests per second
Setting 16000 requests per second (80%) for Transactions criteria.
Note: Transactions per second might not be 1 to 1 with requests per second 
Aggregating as total for 5 minute window size.
*/ -}}
{{- $transactionsCriteria := dict 
    "metricName" "Transactions"
    "metricNamespace" "microsoft.storage/storageaccounts"
    "operator" "GreaterThan"
    "threshold" (16000 | mulf 300)
    "timeAggregation" "Total"
-}}
{{- $storageAccountTransactionsAlert := dict 
    "global" .global
    "name" (printf "transactions-morethanthreshold-%s" .storageAccountName)
    "annotations" $annotations
    "criteria" $transactionsCriteria
    "evaluationFrequency" "PT1M"
    "owner" $owner
    "scopeReference" $scopeReference
    "severity" 2 
    "windowSize" "PT5M"
    "description" (printf "Storage account '%s' transactions more than threshold." .storageAccountName | quote)
-}}
{{- /* Setting throttling encountered alert based on Transaction Response Type
ClientAccountBandwidthThrottlingError: The request is throttled on bandwidth for exceeding storage account scalability limits.
ClientAccountRequestThrottlingError: The request is throttled on request rate for exceeding storage account scalability limits.
ClientThrottlingError: Other client-side throttling error. ClientAccountBandwidthThrottlingError and ClientAccountRequestThrottlingError are excluded.
Refer https://learn.microsoft.com/en-us/azure/storage/blobs/monitor-blob-storage-reference */ -}}
{{- $throttlingResponseTypes := dict 
    "name" "ResponseType"
    "operator" "Include"
    "values" (list "ClientThrottlingError" "ClientAccountBandwidthThrottlingError" "ClientAccountRequestThrottlingError" )
-}}
{{- $throttlingCriteria := dict 
    "metricName" "Transactions"
    "metricNamespace" "microsoft.storage/storageaccounts"
    "operator" "GreaterThan"
    "threshold" 0
    "timeAggregation" "Total"
    "dimensions" (list $throttlingResponseTypes)
-}}
{{- $storageAccountThrottlingAlert := dict 
    "global" .global
    "name" (printf "requests-throttled-%s" .storageAccountName)
    "annotations" $annotations
    "criteria" $throttlingCriteria
    "evaluationFrequency" "PT1M"
    "owner" $owner
    "scopeReference" $scopeReference
    "severity" 2 
    "windowSize" "PT5M"
    "description" (printf "Storage account '%s' requests throttled." .storageAccountName | quote)
-}}
{{- include "aso2.metricAlert" $storageAccountCapacityAlert -}}
{{- include "aso2.metricAlert" $storageAccountAvailabilityAlert -}}
{{- include "aso2.metricAlert" $storageAccountIngressAlert -}}
{{- include "aso2.metricAlert" $storageAccountEgressAlert -}}
{{- include "aso2.metricAlert" $storageAccountTransactionsAlert -}}
{{- include "aso2.metricAlert" $storageAccountThrottlingAlert -}}
{{- end -}}