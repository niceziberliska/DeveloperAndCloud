function GetComputerinformation{

    $Get_Name = (gwmi win32_computersystem).name
    $Get_Model = (gwmi win32_computersystem).Model
    $Get_Memory = "{0:N2}" -f ([math]::Round((gwmi win32_computersystem).Totalphysicalmemory / 1gb))
    $Get_CPU = (gwmi win32_processor).name
    $Get_HDD = "{0:N2}" -f ([math]::round((gwmi win32_logicaldisk | Where-Object {$_.DriveType -like '3' -and $_.DeviceID -like "C:"}).size /1gb))
    $Get_HDD_Freespace = "{0:N2}" -f ([math]::round((gwmi win32_logicaldisk | Where-Object {$_.DriveType -like '3' -and $_.DeviceID -like "C:"}).FreeSpace /1gb))
    $Get_Serialnumber = (gwmi win32_bios).serialnumber
    $Get_Username = $env:USERNAME
    $Get_OS = (Get-WmiObject -Class Win32_OperatingSystem).caption

    $ComputerInformation = New-Object PSObject

    Add-Member -InputObject $ComputerInformation -MemberType NoteProperty -Name "Device Name" -Value "$Get_Name"
    Add-Member -InputObject $ComputerInformation -MemberType NoteProperty -Name Model -Value "$Get_Model"
    Add-Member -InputObject $ComputerInformation -MemberType NoteProperty -Name "Ram Memory" -Value "$Get_Memory"
    Add-Member -InputObject $ComputerInformation -MemberType NoteProperty -Name CPU -Value "$Get_CPU"
    Add-Member -InputObject $ComputerInformation -MemberType NoteProperty -Name HDD -Value "$Get_HDD"
    Add-Member -InputObject $ComputerInformation -MemberType NoteProperty -Name "Serial Number" -Value "$Get_Serialnumber"
    Add-Member -InputObject $ComputerInformation -MemberType NoteProperty -Name "Username" -Value "$Get_Username"
    Add-Member -InputObject $ComputerInformation -MemberType NoteProperty -Name "OperatingSystem" -Value "$Get_OS"

    return $ComputerInformation
}




$DataInfo = GetComputerinformation | Select-Object "Device Name","Model","CPU","Ram Memory","HDD","Serial number", "Username", "OperatingSystem"| ConvertTo-Json

$WebbUri = "https://prod-184.westeurope.logic.azure.com:443/workflows/27308c9bb2ba42168ef88e377bef8c98/triggers/manual/paths/invoke?api-version=2016-06-01"
Invoke-RestMethod -Method "Post" -Uri $WebbUri -Body $DataInfo -ContentType "application/json"




