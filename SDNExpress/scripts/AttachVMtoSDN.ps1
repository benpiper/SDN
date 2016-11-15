### Attach VM to dbtier vnet

#Prerequisites: VM already built using lability

#Shut down VM and move to sdnswitch
$na = Get-VMNetworkAdapter -VMName DC1
Connect-VMNetworkAdapter -SwitchName "sdnSwitch" -VMNetworkAdapter $na

#Grab NC functions
. .\NetworkControllerRESTWrappers.ps1 -ComputerName nc1.company.pri -UserName "company\administrator" -Password "Tr@ining123"

$vnet = Get-NCVirtualNetwork -ResourceId "company_vnet1" #"$($node.TenantName)_$($network.ID)" #probably company_vnet1
$vsubnet = Get-NCVirtualSubnet -VirtualNetwork $vnet -ResourceId "dbtier_subnet" #$Network.Subnets[$using:VMInfo.subnet].ID #dbtier_subnet
#can resourceid (guid?) below be randomly generated on the fly and used?
#MAC address must be static and match the VMs actual MAC
$newguid = [System.Guid]::NewGuid().toString()
$vnic = New-NCNetworkInterface -resourceId "$newguid" -Subnet $vsubnet -IPAddress "192.168.80.9" -MACAddress "001DC8B70110" #-DNSServers $network.DNSServers
$vnicInstanceId = Get-NCNetworkInterfaceInstanceId -ResourceId $newguid
Set-PortProfileId -resourceID ($vnicInstanceId) -VMName "DC1" #-ComputerName $using:hostNode.NodeName