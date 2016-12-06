### Add ACL rule to deny PowerShell access inbound into the apptier subnet

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
$acl.properties.aclRules += New-NCAccessControlListRule -Protocol "tcp" -SourcePortRange "0-65535" -DestinationPortRange "5985" -SourceAddressPrefix "*" -DestinationAddressPrefix "*" -Action "Deny" -Logging $true -ACLType "inbound" -Priority 100

#Add the rule to the ACL
New-NCAccessControlList -ResourceID $acl.resourceId -AccessControlListRules $acl.properties.aclRules -Verbose

#Verify the ACL has the new rule
$acl = Get-NCAccessControlList | where {$_.resourceRef -eq $aclref}
$acl.properties.aclRules.properties | Select * -ExcludeProperty provisioningstate | ft