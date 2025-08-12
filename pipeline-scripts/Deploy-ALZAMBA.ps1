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
    [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

    [Parameter()]
    [String]$azTemplateUri = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/main/patterns/alz/alzArm.json",

    [Parameter()]
    [String]$azTemplateParameterFile = "config\custom-parameters\json\alzArm.$($env:VAR_ENV).param.json",

    [Parameter()]
    [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Create the Azure Management Subscription name
$azManSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azMgmt.ToUpper())

# Get the Management Subscription Alias Id
$azManSubAliasId = Get-AzSubscription -SubscriptionName $azManSubName
$azManagementSubscriptionId = $azManSubAliasId.Id

# Parameters necessary for deployment
$inputObject = @{
    DeploymentName           = -join ('alz-AzMonitorBaselineAlertsDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location                 = $azLocation
    ManagementGroupId        = $azTopLevelMGPrefix
    TemplateUri              = $azTemplateUri
    TemplateParameterFile    = $azTemplateParameterFile
    managementSubscriptionId = $azManagementSubscriptionId
    WhatIf                   = $WhatIfEnabled
    Verbose                  = $true   
}

New-AzManagementGroupDeployment @inputObject
