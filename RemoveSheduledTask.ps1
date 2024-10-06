Get-ScheduledTask | Where-Object {$_.TaskName -match "Sync" -or $_.TaskName -match "sync" -or $_.TaskName -match "Run"} 

Get-Command -Name "*scheduled*"

Unregister-ScheduledTask -TaskName "Shutdown Computer", "Shutdown Computer1" 

