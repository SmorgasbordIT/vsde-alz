param (
  [Parameter()]
  [String]$azUk = "$($env:AZUREUK)",

  [Parameter()]
  [String]$azSnk = "$($env:SPACENK_ABBR)",

  [Parameter()]
  [String]$azEnvHub = "$($env:ENV_HUB)",

  [Parameter()]
  [String]$azId = "$($env:ID_GRP_NAME)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\multipleResourceGroups\multipleResourceGroups.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\resourceGroupIdentity.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($env:WHAT_IF_ENABLED)
)

# Create the Azure Identity Subscription name
$azIdSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azId.ToUpper())

# Get the Management Subscription Alias Id
$azIdSubAliasId = Get-AzSubscription -SubscriptionName $azIdSubName
$azIdentitySubscriptionId = $azIdSubAliasId.Id

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-IdentityRGDeploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  Location              = $azLocation
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $azIdentitySubscriptionId

Write-Output "WhatIfEnabled: $WhatIfEnabled"

# Execute deployment
If($WhatIfEnabled) {
  $azDeploymentOutput = New-AzSubscriptionDeployment @inputObject -WhatIf
}Else{
  $azDeploymentOutput = New-AzSubscriptionDeployment @inputObject
}

# Output to GitHub Actions log
$azDeploymentOutput.Properties.Outputs.outSubscriptionDetails.value `
| ForEach-Object { $_.Name } `
| ConvertTo-Json -Depth 5