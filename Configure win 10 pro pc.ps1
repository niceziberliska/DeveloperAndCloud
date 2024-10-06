$VMName = "maxtechpc1"


Write-Verbose "The detalis of the local administrator account is defind" -Verbose

Write-Verbose "The user name of the local administrator account on the local vm" -Verbose
$NameOfTheLocalAdministratorAccount = "Administrator\$VMName"

Write-Verbose "The password of the local administrator accouunt on the VM" -Verbose
$PasswordOfTheLocalAdministratorAccounnt = ConvertTo-SecureString -String "MOV2023" -AsPlainText -Force

Write-Verbose "This line code makes it possible for powerhsell to executed  code aginst the vm whcih require ahutentication" -Verbose
$LocalCredentialOfTheVM = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $NameOfTheLocalAdministratorAccount, $PasswordOfTheLocalAdministratorAccounnt


$ScriptBlockOne = {
 
 

Write-Verbose "This line of code chnage the computer name by usning VM name variable." -Verbose
    Rename-Computer -NewName $using:VMName -Restart -Force
}  
Invoke-Command -VMName $VMName -ScriptBlock $ScriptBlockOne 



Write-Verbose "These two while loops make powershell waiting until the VM is running before more code is executed" -Verbose 
while ((icm -VMName $VMName -Credential $LocalCredentialOfTheVM {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}

while ((icm -VMName $VMName -Credential $LocalCredentialOfTheVM {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}

$ScriptBlockTwo = {
 
 


$InterFaceIndex = (Get-NetAdapter -name 'Ethernet').InterfaceIndex
$DnsServers = "192.168.1.10" 



    Write-Verbose "This code line set the DNS server addresses for the interface you have specified" -Verbose
    Set-DnsClientServerAddress -InterfaceIndex $InterFaceIndex -ServerAddresses $DnsServers

   
} 
Invoke-Command -VMName $VMName -Credential $LocalCredentialOfTheVM -ScriptBlock $ScriptBlockTwo 



$DomainName = "maxtech" 

#Domän admin konto används efter att du har promota server till AD
$DomainUser = "$DomainName\administrator"
$DomainPWord = ConvertTo-SecureString -String "MOV2023" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord


Write-Verbose "These two while loops make powershell waiting until the VM is running before more code is executed" -Verbose 
while ((icm -VMName $VMName -Credential $LocalCredentialOfTheVM {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}

while ((icm -VMName $VMName -Credential $LocalCredentialOfTheVM {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}

$ScriptBlockThree = {

  Add-Computer -DomainName mstile.se -Credential $using:DomainCredential
        Restart-Computer -Force

}
Invoke-Command -VMName $VMName -Credential $LocalCredentialOfTheVM -ScriptBlock $ScriptBlockThree