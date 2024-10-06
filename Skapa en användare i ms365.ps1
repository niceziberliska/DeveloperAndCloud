$Credential = get-credential

Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All",”Directory.ReadWrite.All”


$NewPassword = @{}
$NewPassword["Password"]= "Sommar2020!"
$NewPassword["ForceChangePasswordNextSignIn"] = $True

New-MgUser -UserPrincipalName "ina.lind@MaxTornqvistITtekniker.onmicrosoft.com" -DisplayName "Ina Lind" -PasswordProfile $NewPassword -AccountEnabled -MailNickName ina-lind -City Kungbacka -CompanyName "Max Törnqvist IT-Tekniker" -Country "Sweden" -Department "Administration" -JobTitle "Administration" -BusinessPhones "+1 676 830 1101" -MobilePhone "+1 617 4466615" -State "Hallnd" -StreetAddress "1, Avenue of the Americas" -Surname "Ina" -GivenName "Lind" -UsageLocation "SE" -OfficeLocation "Kungsbacka"



Get-Mgsubscribedsku | Format-Table SkuPartNumber, Skuid, ConsumedUnits

Set-MgUserLicense -UserId "ina.lind@MaxTornqvistITtekniker.onmicrosoft.com" -AddLicenses @{SkuId = '3b555118-da6a-4418-894f-7df1e2096870'} -RemoveLicenses @()

Get-MgUserLicenseDetail -Userid "ina.lind@MaxTornqvistITtekniker.onmicrosoft.com" | Format-Table SkuId, SkupartNumber