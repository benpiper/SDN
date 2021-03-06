﻿@{
    AllNodes = 
    @(        
        @{ 
            NodeName="*"              # * indicates this section applies to all nodes.  Don't change it.
            
            InstallSrcDir="\\$env:Computername\SDNExpress"

            #VM Creation variables
                        
            VHDName="2016_x64_Datacenter_Core_EN_Eval.vhdx"    # Name of the VHDX to use for VM creation. must exist in the images path under InstallSrcDir
            ProductKey=""                                                                               # Can be blank if using a volume license, or you are deploying in eval mode.  (Don't forget to press "skip").

            #Update to a local path on the hyper-v hosts if local storage, or a UNC path for shared storage  
            VMLocation="c:\sdnvm"                                          #Example: "C:\ClusterStorage\Volume1\VMs"
            
            # Network controller computer name with FQDN
            NetworkControllerRestName = "nc1.$env:USERDNSDOMAIN"        #Example (after evaluation of $env:USERDNSDOMAIN): myname.contoso.com
            
            #This is the name of the virtual switch that must exist on each host.  Note: if you have any 
            #Hyper-V hosts which virtual switches that are named differently, you can override this variable
            #by adding it to the "HyperVHost" role nodes as needed.
            vSwitchName = "sdnSwitch"                                       #Example: SDNSwitch

            #This is the user account and password that the Service Fabric cluster nodes will use for communicating with each other
            #The NCClusterUsername must contain the Domain name in the format DOMAIN\User
            NCClusterUsername = 'company\administrator'                               #Example: CONTOSO\AlYoung
            NCClusterPassword = 'Tr@ining123'                               #Example: MySuperS3cretP4ssword

            #Password to assign to the local administrator of created VMs
            VMLocalAdminPassword = 'Tr@ining123'                              #Example: "V3ryC0mplexP4ssword"
            
            #iDNS is a shared name resolution service. Change this to $false if you you want to use your own DNS server.
            UseIDns = $false                                                   

            #Virtual network information.  You don't need to change this, unless you want to.
            Network = @{
                    ID  = "VNet1"
                    DNSServers = @("192.168.80.10")                             #Example: @("10.60.34.9")
                    Subnets = @(
                        @{
                           ID = "AppTier_Subnet"
                           AddressSpace = "192.168.90.0"
                           Gateway = "192.168.90.1"
                           Mask = "24"
                           ACLGuid = "d7ae4460-694d-0000-1111-4943211728a9"
                         },
                        @{
                           ID = "InfraTier_Subnet"
                           AddressSpace = "192.168.80.0"
                           Gateway = "192.168.80.1"
                           Mask = "24"
                           AclGuid = "e32a6d3c-7082-0000-1111-9bd5fa05bbc9"
                         }
                    )
                    HNVLN_GUID = "bb6c6f28-bad9-441b-8e62-57d2be255904"                  
             }

             VIPLN_GUID = "f8f67956-3906-4303-94c5-09cf91e7e311"

             #VIP for web tier.  Must come from VIP subnet passed into SDNExpress.
             VIPIP = "192.168.3.158"                                            #Example: "10.127.134.133"

             NetworkInterfaces = @{
                AppTier = @("6daca142-7d94-0000-1111-c38c0141be06", "e8425781-5f40-0000-1111-88b7bc7620ca")
                InfraTier = @("334b8585-e6c7-0000-1111-ccb84a842922")
             }

             TenantName = "PS"                                       #Example: "Contoso"

             #
             #You generally don't need to change the rest of the values in this section
             #

             VHDSrcLocation="Images"              
             ConfigurationSrcLocation="TenantApps"

             #These are locations that exist on the hyper-v host or in VMs that will get created as needed
             MountDir="C:\Temp"                                                                

            #Version of this config file. Don't change this.
            ConfigFileVersion="1.0"
         },
        
        @{ 
            # Host to create a web tier VM on.
            NodeName="HYPERV1"                                            #Example: "Host-02"
            Role="HyperVHost"
            VMs=@(
                # Customization information for WebTier VM.  You don't need to change this  unless you changed the virtual network information above.
                @{  
                    VMName="FILE3"
                    VMMemory=2GB
                    ResourceId="6daca142-7d94-0000-1111-c38c0141be06"
                    Subnet=0
                    IPAddress="192.168.90.3"
                    MacAddress="001DC8B70100"
                    PageColor="green"
                    Role="WebTier"
                },
                @{ 
                    VMName="FILE4"
                    VMMemory=2GB
                    ResourceId="e8425781-5f40-0000-1111-88b7bc7620ca" 
                    Subnet=0
                    IPAddress="192.168.90.4"
                    MacAddress="001DC8B70101"
                    PageColor="blue"
                    Role="WebTier"
                }<#,
                @{ 
                    VMName="T1DBTier-VM1"
                    VMMemory=2GB
                    ResourceId="334b8585-e6c7-0000-1111-ccb84a842922" 
                    Subnet=1
                    IPAddress="192.168.80.10"
                    MacAddress="001DC8B70102"
                    PageColor="white"
                    Role="DBTier"
                }#>
            )
         }
        <#@{ 
            # Host to create additoinal VMs on.
            NodeName="HYPERV1"                                            #Example: "Host-03"
            Role="HyperVHost"
            VMs=@(
                # Customization information.  You don't need to change this  unless you changed the virtual network information above.
                @{ 
                    VMName="T1WebTier-VM2"
                    VMMemory=2GB
                    ResourceId="e8425781-5f40-0000-1111-88b7bc7620ca" 
                    Subnet=0
                    IPAddress="192.168.0.11"
                    MacAddress="001DC8B70101"
                    PageColor="blue"
                    Role="WebTier"
                },
                @{ 
                    VMName="T1DBTier-VM1"
                    VMMemory=2GB
                    ResourceId="334b8585-e6c7-0000-1111-ccb84a842922" 
                    Subnet=1
                    IPAddress="192.168.1.10"
                    MacAddress="001DC8B70102"
                    PageColor="white"
                    Role="DBTier"
                }
            )
         },#>

        @{
            NodeName="localhost"
            Role="RestHost"
        
            # Tenant S2S Tunnel connections
            NetworkConnections = 
            @(
                @{
                    # Tunnel name, will be used for Network Connection Resource Id as well
                    TunnelName = "IPSecGW"
                    TunnelType = "IPSec"
                    OutboundCapacity = "100000"
                    InboundCapacity = "100000"

                    # Post connect routes over the tunnel
                    # The current /32 route is the Enterprise BGP Router's IP Address
                    # You can also add multiple subnets here
                    Routes = @(
                        @{
                            Prefix = "192.168.3.1/32"
                            Metric = 10
                        }
                    )
                    IPAddresses = @()
                    PeerIPAddresses = @()

                    # Tunnel Destination (Enterprise Gateway) IP Address
                    DestinationIPAddress = "192.168.3.1"                                      #Example: "10.127.134.121"
                    # Pre Shared Key (Only PSK is enabled via this script for IPSec VPN)
                    SharedSecret = "111_aaa"                      
                },
                @{
                    # Tunnel name, will be used for Network Connection Resource Id as well
                    TunnelName = "GreGW"
                    TunnelType = "Gre"
                    OutboundCapacity = "100000"
                    InboundCapacity = "100000"
                    
                    # Post connect routes over the tunnel
                    # The current /32 route is the Enterprise BGP Router's IP Address
                    # You can also add multiple subnets here
                    Routes = @(
                        @{
                            Prefix = "192.168.3.1/32"
                            Metric = 10
                        }
                    )
                    IPAddresses = @()
                    PeerIPAddresses = @()
                    
                    # Tunnel Destination (Enterprise Gateway) IP Address
                    DestinationIPAddress = "192.168.3.1"                                      #Example: "10.127.134.122"
                    # GRE Key for Tunnel Isolation 
                    GreKey = "1234"                      
                },
                @{
                    # Tunnel name, will be used for Network Connection Resource Id as well
                    TunnelName = "L3GW"
                    TunnelType = "L3"
                    OutboundCapacity = "100000"
                    InboundCapacity = "100000"
                    
                    # VLAN subnet network used for L3 forwarding
                    Network = @{
                        GUID = "L3_Network"        
                        Subnets = @(
                            @{
                                Guid = "L3_Subnet1"
                                AddressSpace = "192.168.3.0"                                  #Example: "10.127.134.0"
                                Mask = "24"                                          #Example: 25
                                DefaultGateway = "192.168.3.1"                                #Example: "10.127.134.1"
                                VlanId = "0"                                        #Example: 1001
                            }
                        )
                    }
                    # Post connect routes over the tunnel
                    # The current /32 route is the Enterprise BGP Router's IP Address
                    # You can also add multiple subnets here
                    Routes = @(
                        @{
                            Prefix = "192.168.3.1/32"
                            Metric = 10
                        }
                    )
                    # Local HNV Gateway's L3 Forwarding IP Address
                    IPAddresses = @(
                        @{
                            IPAddress = "192.168.3.1"                                        #Example: "10.127.134.55"
                            Mask = "24"                                             #Example: 25
                        }
                    )
                    # Remote Gateway's L3 Forwarding IP Address
                    PeerIPAddresses = @("192.168.3.1")                                       #Example: @("10.127.134.65")
                }
            )

            GatewayPools = @("default")

            RoutingType = "Dynamic"

            BgpRouter = @{
                RouterId = "Vnet_Router1"
                LocalASN = 64510
                RouterIP = "192.168.3.9"
            }

            BgpPeers = 
            @(
                @{
                    PeerName = "SiteA_IPSec"
                    PeerIP   = "192.168.3.1"
                    PeerASN  = 64521
                },
                @{
                    PeerName = "SiteB_Gre"
                    PeerIP   = "192.168.3.1"
                    PeerASN  = 64522
                },
                @{
                    PeerName = "SiteC_L3"
                    PeerIP   = "192.168.3.1"
                    PeerASN  = 64523
                }
            )

<#          ##
            ## Example structure for BGP Routing Policy definitions
            ## For more information on BGP Routing policy attributes, please refer to the TechNet Documentation (https://technet.microsoft.com/en-us/library/dn262662(v=wps.630).aspx) ##
            ##

            PolicyMaps = @(
                @{
                    PolicyMapName = "IngressPolicyMap1"
                    PolicyList = @(
                        @{
                            PolicyName = "IngressPolicy1"
                            PolicyType = "Deny"
                            MatchCriteria = @(
                                @{
                                    Clause = "MatchPrefix"
                                    Value  = @("5.4.3.2/32", "5.4.3.1/32")
                                },
                                @{
                                    Clause = "NextHop"
                                    Value  = @("4.3.2.1", "6.4.3.1")
                                }
                            )
                            SetAction = @()
                        }
                    )
                },
                @{
                    PolicyMapName = "EgressPolicyMap1"
                    PolicyList = @(
                        @{
                            PolicyName = "EgressPolicy1"
                            PolicyType = "Permit"
                            MatchCriteria = @(
                                @{
                                    Clause = "IgnorePrefix"
                                    Value  = @("3.3.3.3/32")
                                }
                            )
                            SetAction = @(
                                @{
                                    Clause = "LocalPref"
                                    Value  = @("123")
                                }
                            )
                        }
                    )
                }
            )
#>

         }
     )
}
