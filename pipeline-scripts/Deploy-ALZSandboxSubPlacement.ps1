param (

    [Parameter()]
    [String]$azLocation = "$($env:UKS_LOCATION)",

    [Parameter()]
    [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

    [Parameter()]
    [String]$azSnd = "$($env:ENV_SANDBOX)",

    [Parameter()]
    [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\sandboxSubPlacement\sandboxSubPlacement.bicep",

    [Parameter()]
    [String]$azTemplateParameterFile = "config\custom-parameters\sandboxSubPlacement.parameters.all.bicepparam",

    [Parameter()]
    [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($env:WHAT_IF_ENABLED)
)

# Create the Sandbox Management Group ID
$azMgSandbox = ('{0}-{1}' -f $azTopLevelMGPrefix.ToLower(),$azSnd.ToLower())

# Parameters necessary for deployment
$inputObject = @{
    DeploymentName        = -join ('alz-SandboxSubPlacementDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $azLocation
    ManagementGroupId     = $azMgSandbox
    TemplateFile          = $azTemplateFile
    TemplateParameterFile = $azTemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true   
}

New-AzManagementGroupDeployment @inputObject