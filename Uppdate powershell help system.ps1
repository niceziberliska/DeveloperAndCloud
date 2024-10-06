


#Uppdates powershell from the internet
Update-Help -Force -Verbose

 
# Download help files form the internet and saves them at a specifed location
Save-help -DestinationPath "C:\help" -force -Verbose 

#uppdate help files in powerhsell by using downloeded help files from the internet
Update-Help -SourcePath "C:\help" -force -verbose 

$PSVersionTable