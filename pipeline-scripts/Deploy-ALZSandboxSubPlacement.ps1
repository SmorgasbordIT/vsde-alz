param (

    [Parameter()]
    [String]$azLocation = "$($env:UKS_LOCATION)",

    [Parameter()]
    [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

    [Parameter()]
    [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\sandboxSubPlacement\sandboxSubPlacement.bicep",

    [Parameter()]
    [String]$azTemplateParameterFile = "config\custom-parameters\sandboxSubPlacement.parameters.all.bicepparam",

    [Parameter()]
    [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
    DeploymentName        = -join ('alz-SandboxSubPlacementDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $azLocation
    ManagementGroupId     = $azTopLevelMGPrefix
    TemplateFile          = $azTemplateFile
    TemplateParameterFile = $azTemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true   
}

New-AzManagementGroupDeployment @inputObject

