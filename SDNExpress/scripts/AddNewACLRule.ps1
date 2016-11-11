### Add ACL rule to deny RDP access inbound into the webtier subnet

. .\NetworkControllerRESTWrappers.ps1 -ComputerName nc1.company.pri

#Get virtual network
$vnet = Get-NCVirtualNetwork
$vnet

#Get virtual subnet
$vsn = Get-NCVirtualSubnet -VirtualNetwork $vnet
$vsn

#Get ACL resource reference of webtier subnet
$aclref = $vsn[0].properties.accessControlList.resourceRef
$aclref

#Get ACL
$acl = Get-NCAccessControlList | where {$_.resourceRef -eq $aclref}

#View rules
$acl.properties.aclRules.properties | ft

#Create a new rule to deny RDP into webtier subnet
$acl.properties.aclRules += New-NCAccessControlListRule -Protocol "tcp" -SourcePortRange "0-65535" -DestinationPortRange "3389" -SourceAddressPrefix "*" -DestinationAddressPrefix "*" -Action "Deny" -Logging $true -ACLType "inbound" -Priority 101

#Add the rule to the ACL
New-NCAccessControlList -ResourceID $acl.resourceId -AccessControlListRules $acl.properties.aclRules -Verbose

#Verify the ACL has the new rule
$acl = Get-NCAccessControlList | where {$_.resourceRef -eq $aclref}
$acl.properties.aclRules.properties | ft

#Test RDP connectivity