param (
  [Parameter()]
  [String]$azUk = "$($env:AZUREUK)",

  [Parameter()]
  [String]$azSnk = "$($env:SPACENK_ABBR)",

  [Parameter()]
  [String]$azEnvHub = "$($env:ENV_HUB)",

  [Parameter()]
  [String]$azConn = "$($env:CONN_GRP_NAME)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azConnectivityResourceGroup = "$($env:CONNECTIVITY_RESOURCE_GROUP)",

  [Parameter()]
  [String]$azTemplateFile = "upstream-releases\$($env:UPSTREAM_RELEASE_VERSION)\infra-as-code\bicep\modules\hubNetworking\hubNetworking.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\hubNetworking.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Create the Azure Connectivity Subscription name
$azConnSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azConn.ToUpper())

# Get the Management Subscription Alias Id
$azConnSubAliasId = Get-AzSubscription -SubscriptionName $azConnSubName
$azConnectivitySubscriptionId = $azConnSubAliasId.Id

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-Hub-and-SpokeDeploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  ResourceGroupName     = $azConnectivityResourceGroup
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $azConnectivitySubscriptionId

# Execute deployment
If($WhatIfEnabled) {
  $azDeploymentOutput = New-AzResourceGroupDeployment @inputObject -WhatIf
}Else{
  $azDeploymentOutput = New-AzResourceGroupDeployment @inputObject
}