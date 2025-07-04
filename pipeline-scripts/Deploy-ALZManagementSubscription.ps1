param (

    [Parameter()]
    [String]$azLocation = "$($env:UKS_LOCATION)",

    [Parameter()]
    [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

    [Parameter()]
    [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\managementSubscription\managementSubscription.bicep",

    [Parameter()]
    [String]$azTemplateParameterFile = "config\custom-parameters\managementSubscription.parameters.all.bicepparam",

    [Parameter()]
    [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($env:WHAT_IF_ENABLED)
)

# Parameters necessary for deployment
$inputObject = @{
    DeploymentName        = -join ('alz-ManagementSubscriptionDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $azLocation
    ManagementGroupId     = $azTopLevelMGPrefix
    TemplateFile          = $azTemplateFile
    TemplateParameterFile = $azTemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true   
}

New-AzManagementGroupDeployment @inputObject