param (
  [Parameter()]
  [String]$azUk = "$($env:AZUREUK)",

  [Parameter()]
  [String]$azSnk = "$($env:SPACENK_ABBR)",

  [Parameter()]
  [String]$azInfra = "$($env:INFRA_ABBR)",

  [Parameter()]
  [String]$azSndGrpName = "$($env:SND_GRP_NAME)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTemplateFile = "upstream-releases\$($env:UPSTREAM_RELEASE_VERSION)\infra-as-code\bicep\modules\resourceGroup\resourceGroup.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\resourceGroupSandbox.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Create the Azure Management Subscription name
$azSndSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azInfra.ToUpper(),$azSndGrpName.ToUpper())

# Get the Management Subscription Alias Id
$azSndSubAliasId = Get-AzSubscription -SubscriptionName $azSndSubName
$azSandboxSubscriptionId = $azSndSubAliasId.Id

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-LoggingAndSentinelRGDeploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  Location              = $azLocation
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $azSandboxSubscriptionId

New-AzSubscriptionDeployment @inputObject
