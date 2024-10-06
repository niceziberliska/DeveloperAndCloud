#The name of your scheduled task.
$taskName = "Shutdown Computer"

#Describe the scheduled task.
$description = "Shuts computer down daily at 2100 MTN"


#Create a new task action
$taskAction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument 'Stop-Computer -Force'


#Create task trigger 
$taskTrigger = New-ScheduledTaskTrigger -Daily -At 9PM

#Register the new powershell scheduled task
#Register the scheduled task
Register-ScheduledTask `
    -TaskName $taskName `
    -Action $taskAction `
    -Trigger $taskTrigger `
    -Description $description
