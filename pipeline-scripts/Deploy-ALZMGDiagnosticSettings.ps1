param (
  [Parameter()]
  [String]$azLocation = "$($env:LOCATION)",

  [Parameter()]
  [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

  [Parameter()]
  [String]$azManSubName = "$($env:MAN_SUB_NAME)",

  [Parameter()]
  [String]$azTemplateFile = "upstream-releases\$($env:UPSTREAM_RELEASE_VERSION)\infra-as-code\bicep\orchestration\mgDiagSettingsAll\mgDiagSettingsAll.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\mgDiagSettingsAll.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Get the Management Subscription Alias Id
$azManSubAliasId = Get-AzSubscription -SubscriptionName $azManSubName
$azManagementSubscriptionId = $azManSubAliasId.Id

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = 'alz-MGDiagnosticSettings-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  Location              = $azLocation
  ManagementGroupId     = $azTopLevelMGPrefix
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

# Registering 'Microsoft.Insights' resource provider on the Management subscription
Select-AzSubscription -SubscriptionId $azManagementSubscriptionId

$azProviders = @('Microsoft.insights')

Foreach ($azProvider in $azProviders ) {
  $azIterationCount = 0
  $azMaxIterations = 30
  $azProviderStatus = (Get-AzResourceProvider -ListAvailable | Where-Object ProviderNamespace -eq $azProvider).registrationState
  If ($azProviderStatus -ne 'Registered') {
    Write-Output "`n Registering the '$azProvider' provider"
    Register-AzResourceProvider -ProviderNamespace $azProvider
    Do {
      $azProviderStatus = (Get-AzResourceProvider -ListAvailable | Where-Object ProviderNamespace -eq $azProvider).registrationState
      $azIterationCount++
      Write-Output "Waiting for the '$azProvider' provider registration to complete....waiting 10 seconds"
      Start-Sleep -Seconds 10
    } Until ($azProviderStatus -eq 'Registered' -and $azIterationCount -ne $azMaxIterations)
    If ($azIterationCount -ne $azMaxIterations) {
      Write-Output "`n The '$azProvider' has been registered successfully"
    }Else{
      Write-Output "`n The '$azProvider' has not been registered successfully"
    }
  }
}

New-AzManagementGroupDeployment @inputObject
