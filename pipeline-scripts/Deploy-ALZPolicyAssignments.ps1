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
  [String]$azMgmt = "$($env:MAN_GRP_NAME)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

  [Parameter()]
  [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\policy\assignments\alzDefaults\alzDefaultPolicyAssignments.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\alzDefaultPolicyAssignments.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Create the Azure Management Subscription name
$azManSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azMgmt.ToUpper())

# Get the Management Subscription Alias Id
$azManSubAliasId = Get-AzSubscription -SubscriptionName $azManSubName
$azManagementSubscriptionId = $azManSubAliasId.Id

# Create the Azure Connectivity Subscription name
$azConnSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azConn.ToUpper())

# Get the Connectivity Subscription Alias Id
$azConnSubAliasId = Get-AzSubscription -SubscriptionName $azConnSubName
$azConnectivitySubscriptionId = $azConnSubAliasId.Id

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-PolicyAssignmentsDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  Location              = $azLocation
  ManagementGroupId     = $azTopLevelMGPrefix
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  parConnectivitySubscriptionId = $azConnectivitySubscriptionId
  parLoggingSubscriptionId = $azManagementSubscriptionId
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

New-AzManagementGroupDeployment @inputObject