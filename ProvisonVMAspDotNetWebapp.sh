
#!/bin/bash

location=northeurope
vmname=DemoVMAppServer

# Create the resource group
az group create --name demo01 --location $location

# Create the virtual machine
az vm create --resource-group demo01 \
  --name $vmname \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --size Standard_b1s \
  --custom-data @cloud-init-dotnet.sh

# Open port 5000 with priority 1001
az vm open-port --resource-group demo01 --name $vmname --port 5000 --priority 1001