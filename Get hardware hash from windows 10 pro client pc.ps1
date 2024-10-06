Remove-item -LiteralPath "C:\Windows\Panther\unattend.xml" -Recurse -Force

Install-Language -Language sv-SE

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Install-Script -Name Get-WindowsAutopilotInfo
Get-WindowsAutopilotInfo -OutputFile AutopilotHWID.csv
New-Item -ItemType Directory -Path "C:\HWID"
Set-Location -Path "C:\HWID" 
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts" 
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Install-Script -Name Get-WindowsAutopilotInfo 
Get-WindowsAutopilotInfo -OutputFile AutopilotHWID.csv