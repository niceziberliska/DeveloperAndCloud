##################################################################
##########Create Windows Server 2022 from VHDX template###########
##################################################################

Write-Verbose "First - Change the varibles you need adjust some varibles before you run the script" -Verbose

Write-Verbose "The name varible of the VM" -Verbose
$VMName = "maxtechserver01"
 
Write-Verbose "This Varible specfies the name" -Verbose
$VHDXTemplateName = "MaxCompanyTemplateVM.vhdx" 

Write-Verbose "This is the varible of the VHDX source path" -Verbose
$VHDXSourcePath = "C:\VM\Windows vm templates\$($VHDXTemplateName)" 

Write-Verbose "Varible of the vm folder path" -Verbose
$VMFolderPath = "C:\VM"

Write-Verbose "The varible of the VHDX destenation Path" -Verbose
$VHDXDestinationPath = "$VMFolderPath\$VMName\$($VMName).vhdx" 

Write-Verbose "The varible holds the name of the virtual switch" -Verbose
$VirtualSwitchName = "LAN1" #Look at this varible before you run the code to determine if you need to change somethig. 


Write-Verbose "The line of code creates a new vm" -Verbose
New-VM -Name $VMName -Path $VMFolderPath -MemoryStartupBytes 4GB -SwitchName $VirtualSwitchName -Generation 2


Write-Verbose "This line of code right blow adds an extra network adapter to the VM" -Verbose
Add-VMNetworkAdapter -VMName $VMName -SwitchName $VirtualSwitchName


Write-Verbose "This last line of code enbales the VM to intergrate  with the host computer" -Verbose
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VMName


Write-Verbose "this line of code configure the VM with 3 processor count" -Verbose
Set-VM -Name $VMName -ProcessorCount 3 -AutomaticCheckpointsEnabled $false

Write-Verbose "This if statement exist beacuse The VM need a folder to store the VHDX in." -Verbose

if (-not (Test-Path -Path "$VMFolderPath\$VMName")) { 
New-Item -Path "$VMFolderPath\$($VMName)" -ItemType Directory }

Write-Verbose "This line of code copies VHDX templeate the vm folder" -Verbose

Copy-Item -Path $VHDXSourcePath -Destination $VHDXDestinationPath -Force 

Write-Verbose "The line of code attach the vhdx to the VM" -Verbose

Add-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -Path $VHDXDestinationPath  

Write-Verbose "The code in this line set the boot order" -Verbose

Set-VMFirmware -VMName $VMName -FirstBootDevice (Get-VMHardDiskDrive -VMName $VMName)

Write-Verbose "specifies the path of the raiddisks" -Verbose
$RaiddiskPath = "C:\VM\$VMName"

Write-Verbose "Specifies the name suffixes of each raid disk" -Verbose
$suffixes = @("Raid1", "Raid2")

Write-Verbose "the foreach loop creates a VHDX for each suffix in the #$suffixes varible" -Verbose
Foreach ($suffix in $suffixes) {

Write-Verbose "This varible creates the names of the vhdx raid disks" -Verbose
$vhdxName = "$VMname-$suffix.vhdx"

Write-Verbose "This varible specifies where the vhdx raid disks should be created" -Verbose
$vhdxPath = Join-Path -Path $RaiddiskPath -ChildPath $vhdxName

Write-Verbose "This code linte creates the vhdx raid disks in path specified in the #$vhdxPath varible, configures every vhdx with dynamic memory allocation, and configures each disk to have 500 GB in memory" -Verbose
New-VHD -Dynamic -Path $vhdxPath -SizeBytes 500GB 

}

Write-Verbose "This for each loop attach a VHDX for each suffixes in the #$suffixes varible" -Verbose 
foreach ($suffix in $suffixes) {


$vhdxName = "$VMname-$suffix.vhdx"

$vhdxPath = Join-Path -Path $RaiddiskPath -ChildPath $vhdxName

Add-VMHardDiskDrive -VMName $VMname -Path $vhdxPath  

}


Write-Verbose "This line of code configures a key protector for the virtual machine" -Verbose
Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector

Write-Verbose "This line of code right down below configures TPM for the VM" -Verbose
get-vm -Name $VMName | Enable-VMTPM 

Write-Verbose "This line of code below start the VM." -Verbose 
Start-VM -Name $VMName 

Write-Verbose "The detalis of the local administrator account is defind" -Verbose

Write-Verbose "The user name of the local administrator account on the local vm" -Verbose
$NameOfTheLocalAdministratorAccount = "Administrator"

Write-Verbose "The password of the local administrator accouunt on the VM" -Verbose
$PasswordOfTheLocalAdministratorAccounnt = ConvertTo-SecureString -String "MOV2023" -AsPlainText -Force

Write-Verbose "This line code makes it possible for powerhsell to executed  code aginst the vm whcih require ahutentication" -Verbose
$LocalCredentialOfTheVM = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $NameOfTheLocalAdministratorAccount, $PasswordOfTheLocalAdministratorAccounnt

Write-Verbose "These two while loops make powershell waiting until the VM is running before more code is executed" -Verbose 
while ((icm -VMName $VMName -Credential $LocalCredentialOfTheVM {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}

while ((icm -VMName $VMName -Credential $LocalCredentialOfTheVM {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}

$ScriptBlockOne = {
 
 Write-Verbose "This line of code right down below configuers nic-teaming with switchindependent mode" -Verbose
 New-NetLbfoTeam -Name "NICT1" -TeamMembers "Ethernet", "Ethernet 2" -TeamingMode SwitchIndependent 

Write-Verbose "These three varbiles define the ip-adress, ethernet adpater and dns server of the Vm" -Verbose
$NewIPAddress = "192.168.1.12"####You must change the value of is varibale if you will create more than one VM####
$InterFaceIndex = (Get-NetAdapter -name 'NICT1').InterfaceIndex
$DnsServers = "192.168.1.10" 

    Write-Verbose "The line of code below this description change the ip-adress" -Verbose
    New-NetIPAddress -InterfaceAlias "NICT1" -IPAddress $NewIPAddress -PrefixLength 24 -DefaultGateway "192.168.1.1" 

    Write-Verbose "This code line set the DNS server addresses for the interface you have specified" -Verbose
    Set-DnsClientServerAddress -InterfaceIndex $InterFaceIndex -ServerAddresses $DnsServers

    Write-Verbose "This line of code chnage the computer name by usning VM name variable." -Verbose
    Rename-Computer -NewName $using:VMName -Restart -Force
} 
Invoke-Command -VMName $VMName -Credential $LocalCredentialOfTheVM -ScriptBlock $ScriptBlockOne -ArgumentList $vmStatus

