param (
    [Parameter()]
    [String]$azDeploymentName = "$($env:AZ_SUB_DEPLOYMENT_NAME)",

    [Parameter()]
    [String]$Location = "$($env:LOCATION)",

    [Parameter()]
    [String]$TopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

    [Parameter()]
    [String]$TemplateFile = "modules\bicep\$($env:MODULES_RELEASE_VERSION)\managementSubscription\managementSubscription.bicep",

    [Parameter()]
    [String]$TemplateParameterFile = "config\custom-parameters\managementSubscription.parameters.all.bicepparam",

    [Parameter()]
    [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
    DeploymentName        = $azDeploymentName
    Location              = $Location
    ManagementGroupId     = $TopLevelMGPrefix
    TemplateFile          = $TemplateFile
    TemplateParameterFile = $TemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true   
}

New-AzManagementGroupDeployment @inputObject