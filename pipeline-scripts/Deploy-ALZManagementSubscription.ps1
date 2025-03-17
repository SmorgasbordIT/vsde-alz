param (
    [Parameter()]
    [String]$azDeploymentName = "$($env:AZ_SUB_DEPLOYMENT_NAME)",

    [Parameter()]
    [String]$azLocation = "$($env:LOCATION)",

    [Parameter()]
    [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

    [Parameter()]
    [String]$azTemplateFile = "modules\bicep\$($env:MODULES_RELEASE_VERSION)\managementSubscription\managementSubscription.bicep",

    [Parameter()]
    [String]$azTemplateParameterFile = "config\custom-parameters\managementSubscription.parameters.all.bicepparam",

    [Parameter()]
    [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
    DeploymentName        = $azDeploymentName
    Location              = $azLocation
    ManagementGroupId     = $azTopLevelMGPrefix
    TemplateFile          = $azTemplateFile
    TemplateParameterFile = $azTemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true   
}

New-AzManagementGroupDeployment @inputObject