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
  [String]$azId = "$($env:ID_GRP_NAME)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\networking\idNetworking.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\idNetworking.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($env:WHAT_IF_ENABLED)
)

# Create the Azure Connectivity Subscription name
$azIdSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azId.ToUpper())

# Get the Management Subscription Alias Id
$azIdSubAliasId = Get-AzSubscription -SubscriptionName $azIdSubName
$azIdentitySubscriptionId = $azIdSubAliasId.Id

# Create the Netwoking RG name
$azRgIdNetwork = ('{0}{1}-RG-ID-NETWORK-01' -f $azUk.ToUpper(),$azUks.ToUpper())

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-Id-Network-Deploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  ResourceGroupName     = $azRgIdNetwork
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $azIdentitySubscriptionId

Write-Output "WhatIfEnabled: $WhatIfEnabled"

# Execute deployment
If($WhatIfEnabled) {
  $azDeploymentOutput = New-AzResourceGroupDeployment @inputObject -WhatIf
}Else{
  $azDeploymentOutput = New-AzResourceGroupDeployment @inputObject
}