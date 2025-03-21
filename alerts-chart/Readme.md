Creates a resource group called "devonebox"
Creates two storage accounts called
- sdsstoragetele
- sdsstoragetelebackup

Creates alerts in these storage accounts

**Usage**

Navigate to this folder with Chart.yaml and run following commands

helm dependency update .;

***Create namespace***

```
kubectl create namespace alerts-chart
```

Install chart
```
helm install alerts-chart . -n alerts-chart
```

On subsequent runs, upgrade
```
helm upgrade alerts-chart . -n alerts-chart
```