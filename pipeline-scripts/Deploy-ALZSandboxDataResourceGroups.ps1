param (
  [Parameter()]
  [String]$azUk = "$($env:AZUREUK)",

  [Parameter()]
  [String]$azSnk = "$($env:SPACENK_ABBR)",

  [Parameter()]
  [String]$azData = "$($env:DATA_ABBR)",

  [Parameter()]
  [String]$azSndGrpName = "$($env:SND_GRP_NAME)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\multipleResourceGroups\multipleResourceGroups.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\resourceGroupEngSandbox.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($env:WHAT_IF_ENABLED)
)

# Create the Azure Sandbox Subscription name
$azSndSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azData.ToUpper(),$azSndGrpName.ToUpper())

# Get the Sandbox Subscription Alias Id
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
