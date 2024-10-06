﻿Write-Verbose "I defined all verbiles in the first step" -Verbose

Write-verbose "The name varible of the VM"
$VMName = "maxtechpc5"

Write-verbose "This Varible specfies the name" -Verbose
$VHDXTemplateName = "win10templatenoanswerfile.vhdx"

Write-verbose "This is the varible of the VHDX source path" -Verbose
$VHDXSourcePath = "C:\VM\windows vm templates\win10templatenoanswerfile.vhdx"

Write-verbose "Varible of the vm folder path" -Verbose
$VMFolderPath = "C:\VM"

Write-verbose "The varible of the VHDX destenation Path" -Verbose
$VHDXDestinationPath = "$VMFolderPath\$VMName\$($VMName).vhdx" 

Write-verbose "The line of code creates a new vm" -Verbose

New-VM -Name $VMName -Path $VMFolderPath -MemoryStartupBytes 4GB -SwitchName "WAN" -Generation 2 


Write-verbose "This line of code configure the VM with 3 processor count!" -Verbose
Set-VM -Name $VMName -ProcessorCount 3 -AutomaticCheckpointsEnabled $false

Write-Verbose "This line of code below configure the VM guest service" -Verbose
Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface" 

Write-verbose "This if statement exist beacuse The VM need a folder to store the VHDX in." -Verbose

if (-not (Test-Path -Path "$VMFolderPath\$VMName")) { 
New-Item -Path "$VMFolderPath\$($VMName)" -ItemType Directory }

Write-verbose "This line of code copies VHDX templeate the vm folder" -Verbose

Copy-Item -Path $VHDXSourcePath -Destination $VHDXDestinationPath -Force 

Write-verbose "The line of code attach the vhdx to the VM" -Verbose

Add-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -Path $VHDXDestinationPath 


Write-verbose "The code in this line set the boot order" -Verbose

Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMHardDiskDrive -VMName $VMName)

Write-verbose "This line of code below start the VM." -Verbose 
Start-VM -Name $VMName 


