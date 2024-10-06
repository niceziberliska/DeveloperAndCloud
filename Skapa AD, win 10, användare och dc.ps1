#Variabel
$vSwitch = "LAN"
$VHDXName = "Server2022Template.vhdx"
$VHDXCurrentPath = "C:\VM\Server2022Template\Virtual Hard Disks\$VHDXName"
$VHDXDestinationPath = "C:\VM"
$SubMaskBit = "24"

#####################################
#####################################
#####################################
############Skapa ADD01##############

#Skapa variabel för ADD01
#AD Server konfiguration variabel
$ADName = "AD01"
$ADIP = "192.168.10.220"
#Domän information
$DomainMode = "WinThreshold"
$ForestMode = "WinThreshold"
$DomainName = "mstile.se"
$DSRMPWord = ConvertTo-SecureString -String "Sommar2023!" -AsPlainText -Force

#Lokal admin konto används för att kunna logga på ADD01 för att konfigurera samt för invoke-command
$DCLocalUser = "$ADName\Administrator"
$DCLocalPWord = ConvertTo-SecureString -String "MOV2023" -AsPlainText -Force
$DCLocalCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DCLocalUser, $DCLocalPWord

#Domän admin konto används efter att du har promota server till AD
$DomainUser = "$DomainName\administrator"
$DomainPWord = ConvertTo-SecureString -String "MOV2023" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord



Function CreateAD01 {
#Kopiera VM template som vi har skapat.
Write-Verbose "Check if folder for VM exist"

$cpath = Test-Path "C:\VM\$($ADName)"

if($cpath -eq  $false){
    Write-Verbose "Folder doest not exist, creating folder" -Verbose

    New-item -Name $ADName -Path "C:\VM\" -ItemType Directory | Out-Null

    Write-Verbose "Folder is created, copy template VM" -Verbose

    Copy-Item "$VHDXCurrentPath" "$VHDXDestinationPath\$ADNAME\$ADNAME.vhdx"
    
}else{


    Write-Verbose "Folder already exist" -Verbose
    Write-Verbose "copy template VM" -Verbose

    Copy-Item "$VHDXCurrentPath" "$VHDXDestinationPath\$ADNAME\$ADNAME.vhdx"

}



#Skapa VM ADD01
New-VM -Name $ADName -MemoryStartupBytes 2GB -VHDPath "$VHDXDestinationPath\$ADNAME\$ADNAME.vhdx" -Generation 2 -SwitchName $vSwitch 
Set-VM -Name $ADName -AutomaticCheckpointsEnabled $false
Write-Verbose "VM Creation Completed. Starting VM [$ADName]" -Verbose
Start-VM -Name $ADName

#Vänta att VM ska komma igång
Write-Verbose “Waiting for PowerShell Direct to start on VM [$ADName]” -Verbose
   while ((icm -VMName $ADName -Credential $DCLocalCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}

   while ((icm -VMName $ADName -Credential $DCLocalCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}
   


Write-Verbose “[$ADName] is alive moving to IP config and change computername” -Verbose


#Konfigurera IP Adress till ADD01 och byter namn
Invoke-Command -vmname $ADName -Credential $DCLocalCredential -ScriptBlock { 
    
    
    new-NetIPAddress -InterfaceIndex (Get-NetAdapter).ifIndex -IPAddress $using:ADIP -PrefixLength 24 -DefaultGateway 192.168.10.1
    Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses ("8.8.8.8")

    Rename-Computer -NewName $using:ADName -Force

    
} 

#Start om VM efter namnbytet
Write-Verbose "Rebooting VM [$ADName] for hostname change to take effect" -Verbose
Stop-VM -Name $ADName -Force
Start-VM -Name $ADName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$ADName]” -Verbose
   while ((icm -VMName $ADName -Credential $DCLocalCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}



Write-Verbose "PowerShell Direct responding on VM [$ADName]. Moving On...." -Verbose


#Installera ADDS rollen
Invoke-Command -VMName $ADName -Credential $DCLocalCredential -ScriptBlock {

    
    Write-Verbose "Installing Active Directory Services on VM [$using:ADName]" -Verbose
    Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools
    Write-Verbose "Configuring New Domain with Name [$using:DomainName] on VM [$using:ADName]" -Verbose
    Install-ADDSForest -ForestMode $using:ForestMode -DomainMode $using:DomainMode -DomainName $using:DomainName `
    -InstallDns -NoDNSonNetwork -SafeModeAdministratorPassword $using:DSRMPWord -Force -NoRebootOnCompletion
    
    #Restart-Computer
    } -

Write-Verbose "Rebooting VM [$ADName] to complete installation of new AD Forest" -Verbose
Stop-VM -Name $ADName -Force
Start-VM -Name $ADName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$ADName]” -Verbose
   while ((icm -VMName $ADName -Credential $DomainCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}
Write-Verbose "PowerShell Direct responding on VM [$ADName]. Moving On...." -Verbose

Write-Verbose "DC Provisioning Complete!!!!" -Verbose
}
CreateAD01

Function ImportUser{
    $CsvPath = "C:\VM\user.csv"
    $Import_Users = Import-Csv $CsvPath -Encoding UTF8 -Delimiter ","

    Invoke-Command -VMName $ADName -Credential $DomainCredential -ScriptBlock{
    
        foreach($users in $using:Import_Users){
             $MyPassword = "Sommar2023!"
             $MyDomain = (gwmi win32_computersystem).domain
        
             $UserProperties = @{
                SamAccountName  = "$($users.givenname).$($users.surname)"
                UserPrincipalName = "$($users.givenname).$($users.surname)@$($MyDomain)"
                Name           = "$($users.givenname) $($users.surname)"
                GivenName      = "$($users.givenname)"
                Surname        = "$($users.surname)"
                DisplayName    = "$($users.givenname) $($users.surname)"
                AccountPassword = (ConvertTo-SecureString $MyPassword -AsPlainText -Force)
                Enabled        = $true
            }

            New-ADUser @UserProperties 

          

        
                
        
        
        
        }
        
    
    
    
    }


}
ImportUser

Function CreateDHCP{


    Invoke-Command -vmname $ADName -Credential $DomainCredential {

                    # Install the DHCP Server role
                Install-WindowsFeature -Name DHCP -IncludeManagementTools

                # Define DHCP Scope Variables
                $ScopeID = "192.168.10.0"                # Subnet IP
                $StartingRange = "192.168.10.50"         # Start IP for DHCP Lease
                $EndingRange = "192.168.10.100"          # End IP for DHCP Lease
                $SubnetMask = "255.255.255.0"        # Subnet Mask
                $LeaseDuration = "8.00:00:00"        # Lease Duration in Days.Hours:Minutes:Seconds format (e.g., 8 days)
                $ScopeName = "OfficeScope"           # Name for this DHCP Scope
                $ScopeDescription = "Office Network" # Description for this DHCP Scope

                # Define DHCP Option Variables
                $Router = "192.168.10.1"                 # Default Gateway
                $DNSServers = "192.168.10.220"  # Primary and Secondary DNS Server IPs

                # Add the DHCP Scope
                Add-DhcpServerv4Scope -StartRange $StartingRange -EndRange $EndingRange -SubnetMask $SubnetMask -Name $ScopeName -Description $ScopeDescription -LeaseDuration $LeaseDuration

                # Set the DHCP Scope Options
                Set-DhcpServerv4OptionValue -ScopeId $ScopeID -OptionId 3 -Value $Router
                Set-DhcpServerv4OptionValue -ScopeId $ScopeID -OptionId 6 -Value $DNSServers

                # Authorize DHCP Server in Active Directory
                Add-DhcpServerInDC

                # Output to confirm the configuration
                Get-DhcpServerv4Scope | Where-Object { $_.ScopeId -eq $ScopeID } | Format-List
                Get-DhcpServerv4OptionValue -ScopeId $ScopeID


        
    
    
        
    
    
    }








}
CreateDHCP

Function CreateWin10 {
####################################
##############Win10#################


$WinName = "NewWin10"
#Domän information
$DomainName = "mstile.se"
$VHDXWin10Name = "Win10.vhdx"
$VHDXWin10CurrentPath = "C:\VM\Win10\Win10\Virtual Hard Disks\$VHDXWin10Name"
$VHDXWin10DestinationPath = "C:\VM"

#Lokal admin konto används för att kunna logga på ADD01 för att konfigurera samt för invoke-command
$LocalUser = "$WinName\Administrator"
$DCLocalPWord = ConvertTo-SecureString -String "MOV2023" -AsPlainText -Force
$DCLocalCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DCLocalUser, $DCLocalPWord

#Domän admin konto används efter att du har promota server till AD
$DomainUser = "$DomainName\administrator"
$DomainPWord = ConvertTo-SecureString -String "MOV2023" -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord


#Kopiera VM template som vi har skapat.
Write-Verbose "Check if folder for VM exist"

$cpath = Test-Path "C:\VM\$($WinName)"

if($cpath -eq  $false){
    Write-Verbose "Folder doest not exist, creating folder" -Verbose

    New-item -Name $WinNAME -Path "C:\VM\" -ItemType Directory | Out-Null

    Write-Verbose "Folder is created, copy template VM" -Verbose

    Copy-Item "$VHDXWin10CurrentPath" "$VHDXWin10DestinationPath\$WinNAME\$WinNAME.vhdx"
    
}else{


    Write-Verbose "Folder already exist" -Verbose
    Write-Verbose "copy template VM" -Verbose

    Copy-Item "$VHDXWin10CurrentPath" "$VHDXWin10DestinationPath\$WinNAME\$WinNAME.vhdx"

}



#Skapa Win10
New-VM -Name $WinName -MemoryStartupBytes 2GB -VHDPath "$VHDXWin10DestinationPath\$WinNAME\$WinNAME.vhdx" -Generation 2 -SwitchName $vSwitch 
Set-VM -Name $WinName -AutomaticCheckpointsEnabled $false
Write-Verbose "VM Creation Completed. Starting VM [$WinName]" -Verbose
Start-VM -Name $WinName

#Vänta att VM ska komma igång
Write-Verbose “Waiting for PowerShell Direct to start on VM [$WinName]” -Verbose
while ((icm -VMName $WinName -Credential $DCLocalCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}
   


Write-Verbose “[$WinName] is alive moving to IP config and change computername” -Verbose


#Byter namn
Invoke-Command -vmname $WinName -Credential $DCLocalCredential -ScriptBlock { 
  
    write-verbose "Changing computername" -verbose

    Rename-Computer -NewName $using:WinName -Force


}

#Start om VM efter namnbytet
Write-Verbose "Rebooting VM [$WinName] for hostname change to take effect" -Verbose
Stop-VM -Name $WinName -Force
Start-VM -Name $WinName

Write-Verbose "Add Computer to domain [$DomainName]" -Verbose


Invoke-Command -vmname $WinName -Credential $DCLocalCredential -ScriptBlock { 


        Add-Computer -DomainName mstile.se -Credential $using:DomainCredential
        Restart-Computer -Force

  

   

    
    }


}
CreateWin10 

