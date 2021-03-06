﻿### Add ACL rule to deny PowerShell access inbound into the apptier subnet

cd c:\sdn\SDNExpress\scripts

. .\NetworkControllerRESTWrappers.ps1 -ComputerName nc1.company.pri

#Get virtual network
$vnet = Get-NCVirtualNetwork
$vnet

#Get virtual subnet
$infratiersubnet = Get-NCVirtualSubnet -VirtualNetwork $vnet | where {$_.resourceId -eq "InfraTier_Subnet"}
$infratiersubnet

#Get ACL resource reference of infratier subnet
$aclref = $infratiersubnet.properties.accessControlList.resourceRef
$aclref

#Get ACL
$acl = Get-NCAccessControlList | where {$_.resourceRef -eq $aclref}

#View rules
$acl.properties.aclRules.properties | Select * -ExcludeProperty provisioningstate | ft

#Create a new rule to deny PowerShell into infratier subnet
$acl.properties.aclRules += New-NCAccessControlListRule -Logging $true -Protocol "tcp" -SourcePortRange "0-65535" -DestinationPortRange "5985" -SourceAddressPrefix "*" -DestinationAddressPrefix "*" -Action "Deny" -ACLType "inbound" -Priority 100

#Update the ACL with the new rule
New-NCAccessControlList -ResourceID $acl.resourceId -AccessControlListRules $acl.properties.aclRules -Verbose

#Verify the ACL has the new rule
$acl = Get-NCAccessControlList | where {$_.resourceRef -eq $aclref}
$acl.properties.aclRules.properties | Select * -ExcludeProperty provisioningstate | ft

#Remove all deny rules
$acl.properties.aclRules = $acl.properties.aclRules | Where-Object {$_.properties.action -ne "Deny"}
New-NCAccessControlList -ResourceID $acl.resourceId -AccessControlListRules $acl.properties.aclRules -Verbose

#Verify the deny rules have been removed
$acl = Get-NCAccessControlList | where {$_.resourceRef -eq $aclref}
$acl.properties.aclRules.properties | Select * -ExcludeProperty provisioningstate | ft