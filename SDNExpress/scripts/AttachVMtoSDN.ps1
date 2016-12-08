### Attach VM to infratier vnet

#Prerequisites: VM already built using lability

#Shut down VM and move to sdnswitch
Stop-VM -VMName DC-SDN
$na = Get-VMNetworkAdapter -VMName DC-SDN
Connect-VMNetworkAdapter -SwitchName "sdnSwitch" -VMNetworkAdapter $na

#Grab NC functions
. .\NetworkControllerRESTWrappers.ps1 -ComputerName nc1.company.pri -UserName "company\administrator" -Password "Tr@ining123"

$vnet = Get-NCVirtualNetwork -ResourceId "company_vnet1"
$vnet
$vnet.properties
$vnet.properties.addressSpace

$vsubnet = Get-NCVirtualSubnet -VirtualNetwork $vnet -ResourceId "InfraTier_Subnet"
$vsubnet
$vsubnet.properties

#Create virtual network interface on DC-SDN
#MAC address must be static and match the VMs actual MAC
$newguid = [System.Guid]::NewGuid().toString()
$mac = (Get-VMNetworkAdapter -VMName DC-SDN).MacAddress
$vnic = New-NCNetworkInterface -resourceId "$newguid" -Subnet $vsubnet -IPAddress "192.168.90.10" -MACAddress $mac
$vnic
$vnic.properties.ipConfigurations.properties

#Attach DC-SDN to the InfraTier_subnet
$vnicInstanceId = Get-NCNetworkInterfaceInstanceId -ResourceId $newguid
Set-PortProfileId -resourceID ($vnicInstanceId) -VMName "DC-SDN"

#Boot DC-SDN
Start-VM -VMName DC-SDN