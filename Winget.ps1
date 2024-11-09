
$input = Read-Host "Enter 1 for uppdating all software compatibe with winget, and enter 2 to let your system give you an hello"

switch ($input) {
    "1" { 
        ###Check all software for updates, that are compatible with winget
        winget upgrade 
        }
    "2" { 
        echo "hello"
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

###Installs docker desktop on your computer
winget search --name "docker" | winget install --name "Docker Desktop" 


winget search --name "armoury", "asus" |  winget install --id Asus.ArmouryCrate                     