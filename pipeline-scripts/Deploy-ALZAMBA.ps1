param (

    [Parameter()]
    [String]$azLocation = "$($env:UKS_LOCATION)",

    [Parameter()]
    [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

    [Parameter()]
    [String]$azTemplateUri = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/main/patterns/alz/alzArm.json",

    [Parameter()]
    [String]$azTemplateParameterFile = "config\custom-parameters\json\alzArm.param.json",

    [Parameter()]
    [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
    DeploymentName        = -join ('alz-AzMonitorBaselineAlertsDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $azLocation
    ManagementGroupId     = $azTopLevelMGPrefix
    TemplateUri           = $azTemplateFile
    TemplateParameterFile = $azTemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true   
}

New-AzManagementGroupDeployment @inputObject
