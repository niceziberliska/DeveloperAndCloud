# FIrst i defined alla varibles

#The name varible of the VM
$VMName = "maxitsc1"
 

#This Varible specfies the name
$VHDXTemplateName = "windows server 2019 template.vhdx"

#This is the varible of the VHDX source path
$VHDXSourcePath = "C:\VM\windows vm templates\$($VHDXTemplateName)"

#Varible of the vm folder path
$VMFolderPath = "C:\VM"


# The varible of the VHDX destenation Path
$VHDXDestinationPath = "$VMFolderPath\$VMName\$($VMName).vhdx" 

#The line of code creates a new vm

New-VM -Name $VMName -Path $VMFolderPath -MemoryStartupBytes 4GB -SwitchName "LAN1" -Generation 2 


#This line of code configure the VM with 3 processor count
Set-VM -Name $VMName -ProcessorCount 3 -AutomaticCheckpointsEnabled $false


#This if statement exist beacuse The VM need a folder to store the VHDX in.

if (-not (Test-Path -Path "$VMFolderPath\$VMName")) { 
New-Item -Path "$VMFolderPath\$($VMName)" -ItemType Directory }

#This line of code copies VHDX templeate the vm folder


Copy-Item -Path $VHDXSourcePath -Destination $VHDXDestinationPath -Force 


#The line of code attach the vhdx to the VM

Add-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -Path $VHDXDestinationPath  


#The code in this line set the boot order

Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMHardDiskDrive -VMName $VMName)

#This line of code below start the VM. 
Start-VM -Name $VMName 


#This line of code checks if the VM is running, if the if statement finds that the vm is running the if change ip-adress and computername. 
$vmStatus = Get-VM -Name $VMName | Select-Object -ExpandProperty State

$ScriptBlockOne = {
# an if statement that tests if the VM is running 
if ($vmStatus -eq "Running") {
    
Write-Verbose "The VM is curretly not running" -Verbose
 
} else {

$NewIPAddress = "192.168.1.11"
$InterFaceIndex = (Get-NetAdapter -name 'Ethernet').InterfaceIndex
$DnsServers = "192.168.1.10"
$NewComputerName = "maxitsc1" ####$VMName - varibale to use when you chnage the code later # Part of the code to change later####



    # The line of code below this description change the ip-adress
    New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $NewIPAddress -PrefixLength 24 -DefaultGateway "192.168.1.1" 

    #This code line set the DNS server addresses for the interface you have specified 
    Set-DnsClientServerAddress -InterfaceIndex $InterFaceIndex -ServerAddresses $DnsServers

    # This line of code chnage the computer name.
    Rename-Computer -NewName $NewComputerName -Restart 
}
} 
Invoke-Command -VMName $VMName -ScriptBlock $ScriptBlockOne -ArgumentList $vmStatus

