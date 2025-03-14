param (
  [Parameter()]
  [String]$azManSubName = "$($env:MAN_SUB_NAME)",

  [Parameter()]
  [String]$Location = "$($env:LOCATION)",

  [Parameter()]
  [String]$ManagementSubscriptionId = "$($env:MANAGEMENT_SUBSCRIPTION_ID)",

  [Parameter()]
  [String]$TemplateFile = "upstream-releases\$($env:UPSTREAM_RELEASE_VERSION)\infra-as-code\bicep\modules\resourceGroup\resourceGroup.bicep",

  [Parameter()]
  [String]$TemplateParameterFile = "config\custom-parameters\resourceGroupLoggingAndSentinel.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Get the Management Subscription Alias Id
$azManSubAliasId = Get-AzSubscription -SubscriptionName $azManSubName
$ManagementSubscriptionId = $azManSubAliasId.Id

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-LoggingAndSentinelRGDeploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  Location              = $Location
  TemplateFile          = $TemplateFile
  TemplateParameterFile = $TemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $ManagementSubscriptionId

New-AzSubscriptionDeployment @inputObject
