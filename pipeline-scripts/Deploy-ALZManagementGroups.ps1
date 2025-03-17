param (
  [Parameter()]
  [String]$NonRootParentManagementGroupId = "$($env:NONROOTPARENTMANAGEMENTGROUPID)",

  [Parameter()]
  [String]$azLocation = "$($env:LOCATION)",

  [Parameter()]
  [String]$azTemplateFile = "modules\bicep\$($env:MODULES_RELEASE_VERSION)\managementGroups\",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\managementGroups.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
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
