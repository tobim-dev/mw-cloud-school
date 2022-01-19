#!/bin/sh

CLOUDSCHOOL_SUBSCRIPTION_ID=4405c0b5-f638-4e0a-b7e4-c4899d4c8efe
LOCAL_BASEDIR=/mnt/d/Entwicklung/mw-cloud-school/IaaS

cd $LOCAL_BASEDIR

terraform init

az login # will open the browser to log on
az account set --subscription $CLOUDSCHOOL_SUBSCRIPTION_ID
# register the Microsoft.Network namespace, otherwise we cannot create virtual networks
az provider register --namespace Microsoft.Network
# register the Microsoft.Network namespace, otherwise we cannot create virtual machines
az provider register --namespace Microsoft.Compute

terraform plan
# if the resource group already exists, import it first:
terraform import azurerm_resource_group.rg /subscriptions/$CLOUDSCHOOL_SUBSCRIPTION_ID/resourceGroups/Matthias_Ostermaier

terraform apply

# register SSH in the local shell to be able to connect
mkdir -p ~/.ssh
# the following private key file must be in OpenSSH format (may be converted in PuttyGen)
cp keys/id_rsa ~/.ssh/
cp keys/id_rsa.pub ~/.ssh/
chmod -R 700 ~/.ssh

