#!/bin/bash

resource_group=GithubActionsDemoRG
location=swedencentral
vm_name=GithubActionsDemoVM
vm_port=5000

# This line of code below will generate name to ssh keys based on the name of the VM.

ssh_key_name="${vm_name}_ssh_key"

az group create --location $location --name $resource_group

az vm create --name $vm_name --resource-group $resource_group \
             --image Ubuntu2204 \
             --size Standard_B1s \
             --ssh-key-name $ssh_key_name \
             --generate-ssh-keys \
             --admin-username azureuser \
             --custom-data @cloud-init_dotnet.yaml

az vm open-port --port $vm_port --resource-group $resource_group --name $vm_name