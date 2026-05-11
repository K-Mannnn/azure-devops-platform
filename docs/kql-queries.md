
### W4D3

// Query 1 — Key Vault security audit
// When to use: daily security review, incident investigation
AzureDiagnostics
| where TimeGenerated > ago(48h)
| where ResourceType == "VAULTS"
| project TimeGenerated, OperationName, CallerIPAddress, ResultType
| order by TimeGenerated desc



// Query 2 — ACR login audit
// When to use: who logged into the registry and when
ContainerRegistryLoginEvents
| where TimeGenerated > ago(7d)
| project TimeGenerated, OperationName, CallerIpAddress, Identity
| order by TimeGenerated desc


// Query 3 — Azure resource metrics
// When to use: performance baseline across all resources
AzureMetrics
| where TimeGenerated > ago(24h)
| summarize AvgValue = avg(Average) by ResourceProvider, MetricName
| order by AvgValue desc


