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
  [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\multipleResourceGroups\multipleResourceGroups.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\resourceGroupConnectivity.parameters.all.bicepparam",

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
  DeploymentName        = -join ('alz-ConnectivityRGDeploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  Location              = $azLocation
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $azConnectivitySubscriptionId

# Execute deployment
If($WhatIfEnabled) {
  $azDeploymentOutput = New-AzSubscriptionDeployment @inputObject -WhatIf
}Else{
  $azDeploymentOutput = New-AzSubscriptionDeployment @inputObject
}

# Output to GitHub Actions log
$azDeploymentOutput.Properties.Outputs.outSubscriptionDetails.value | ConvertTo-Json -Depth 5