param (
  [Parameter()]
  [String]$azUk = "$($env:AZUREUK)",

  [Parameter()]
  [String]$azSnk = "$($env:SPACENK_ABBR)",

  [Parameter()]
  [String]$azEnvHub = "$($env:ENV_HUB)",

  [Parameter()]
  [String]$azMgmt = "$($env:MAN_GRP_NAME)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTemplateFile = "upstream-releases\$($env:UPSTREAM_RELEASE_VERSION)\infra-as-code\bicep\modules\resourceGroup\resourceGroup.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\resourceGroupLoggingAndSentinel.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($env:WHAT_IF_ENABLED)
)

# Create the Azure Management Subscription name
$azManSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azMgmt.ToUpper())

# Get the Management Subscription Alias Id
$azManSubAliasId = Get-AzSubscription -SubscriptionName $azManSubName
$azManagementSubscriptionId = $azManSubAliasId.Id

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-LoggingAndSentinelRGDeploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  Location              = $azLocation
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $azManagementSubscriptionId

New-AzSubscriptionDeployment @inputObject
