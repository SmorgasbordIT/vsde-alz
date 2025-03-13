param (
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
    DeploymentName        = -join ('alz-ManagementSubscriptionDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $Location
    ManagementGroupId     = $TopLevelMGPrefix
    TemplateFile          = $TemplateFile
    TemplateParameterFile = $TemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true   
}

New-AzManagementGroupDeployment @inputObject