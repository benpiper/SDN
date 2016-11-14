### Attach VM to dbtier vnet

#Prerequisites: VM already built using lability

#Shut down VM and move to sdnswitch

#Grab NC functions
. "$($node.InstallSrcDir)\scripts\NetworkControllerRESTWrappers.ps1" -ComputerName $node.NetworkControllerRestName -UserName $node.NCClusterUserName -Password $node.NCClusterPassword

$vnet = Get-NCVirtualNetwork -ResourceId "$($node.TenantName)_$($network.ID)" #probably company_vnet1
$vsubnet = Get-NCVirtualSubnet -VirtualNetwork $vnet -ResourceId $Network.Subnets[$using:VMInfo.subnet].ID #dbtier_subnet
#can resourceid (guid?) below be randomly generated on the fly and used?
#MAC address must be static and match the VMs actual MAC
$vnic = New-NCNetworkInterface -resourceId $using:VMInfo.ResourceId -Subnet $vsubnet -IPAddress $using:VMInfo.IPAddress -MACAddress $using:VMInfo.MACAddress -DNSServers $network.DNSServers
$vnicInstanceId = Get-NCNetworkInterfaceInstanceId -ResourceId $using:VMInfo.ResourceId
Set-PortProfileId -resourceID ($vnicInstanceId) -VMName ($using:vmInfo.VMName) -ComputerName $using:hostNode.NodeName