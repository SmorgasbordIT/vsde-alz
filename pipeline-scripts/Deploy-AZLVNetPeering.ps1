param (
  [Parameter()]
  [String]$azUk = "$($env:AZUREUK)",

  [Parameter()]
  [String]$azUks = "$($env:AZ_UKSOUTH)",

  [Parameter()]
  [String]$azSnk = "$($env:SPACENK_ABBR)",

  [Parameter()]
  [String]$azEnvHub = "$($env:ENV_HUB)",

  [Parameter()]
  [String]$azEnvId = "$($env:ID_GRP_NAME)",

  [Parameter()]
  [String]$azConn = "$($env:CONN_GRP_NAME)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\vnetPeering\vnetPeering.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\vnetPeering.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($env:WHAT_IF_ENABLED)
)

# Create the Azure ID Subscription name
$azIdSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azEnvId.ToUpper())

# Get the ID Subscription Alias Id
$azIdSubAliasId = Get-AzSubscription -SubscriptionName $azIdSubName
$azIdentitySubscriptionId = $azIdSubAliasId.Id

# Create the Azure Connectivity Subscription name
$azConnSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azConn.ToUpper())

# Get the Connectivity Subscription Alias Id
$azConnSubAliasId = Get-AzSubscription -SubscriptionName $azConnSubName
$azConnectivitySubscriptionId = $azConnSubAliasId.Id

# Create the Netwoking RG name
$azRgConnNetwork = ('{0}{1}-RG-CONN-NETWORK-01' -f $azUk.ToUpper(),$azUks.ToUpper())

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-VNetPeeringDeploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  ResourceGroupName     = $azRgConnNetwork
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  parIdSubscriptionId   = $azIdentitySubscriptionId
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $azConnectivitySubscriptionId

Write-Output "WhatIfEnabled: $WhatIfEnabled"

# Execute deployment
If($WhatIfEnabled) {
  $azDeploymentOutput = New-AzResourceGroupDeployment @inputObject -WhatIf
}Else{
  $azDeploymentOutput = New-AzResourceGroupDeployment @inputObject
}