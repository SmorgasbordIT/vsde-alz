param (
  [Parameter()]
  [String]$NonRootParentManagementGroupId = "$($env:NONROOTPARENTMANAGEMENTGROUPID)",

  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\modules\managementGroups\",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\managementGroups.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($env:WHAT_IF_ENABLED)
)

# Parameters necessary for deployment
If($NonRootParentManagementGroupId -eq '') {
  $inputObject = @{
    DeploymentName        = -join ('alz-MGDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $azLocation
    TemplateFile          = $azTemplateFile + "managementGroups.bicep"
    TemplateParameterFile = $azTemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true
  }

  New-AzTenantDeployment @inputObject
}
If($NonRootParentManagementGroupId -ne '') {
  $inputObject = @{
    ManagementGroupId     = $NonRootParentManagementGroupId
    DeploymentName        = -join ('alz-MGDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    TemplateFile          = $azTemplateFile + "managementGroupsScopeEscape.bicep"
    TemplateParameterFile = $azTemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true
  }

  New-AzManagementGroupDeployment @inputObject
}
