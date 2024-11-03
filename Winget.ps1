
$input = Read-Host "Enter 1 for uppdating all software compatibe with winget"

switch ($input) {
    "1" { 
        winget upgrade 
        }
    Default {}
}
###Get and install MySQL Workbench 8.0 CE

#get MySQL Workbench
winget search --name "sql", "work" 
#Installs MySQL Workbench 
winget install --name "MySQL Workbench 8.0 CE"

###Get And install Oracle VirtualBox
winget install --id Oracle.VirtualBox -e --source winget 

#Check all software for update compatible with winget