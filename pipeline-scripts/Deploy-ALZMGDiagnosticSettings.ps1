param (
  [Parameter()]
  [String]$azLocation = "$($env:UKS_LOCATION)",

  [Parameter()]
  [String]$azTopLevelMGPrefix = "$($env:TOP_LEVEL_MG_PREFIX)",

  [Parameter()]
  [String]$azAzureUk = "$($env:AZUREUK)",

  [Parameter()]
  [String]$azSnk = "$($env:SPACENK_ABBR)",

  [Parameter()]
  [String]$azEnvHub = "$($env:ENV_HUB)",

  [Parameter()]
  [String]$azMgmt = "$($env:MAN_GRP_NAME)",

  [Parameter()]
  [String]$azLawAbbrName = "$($env:LOG_ANALYTICS_ABBR_NAME)",

  [Parameter()]
  [String]$azTemplateFile = "bicep\$($env:MODULES_RELEASE_VERSION)\orchestration\mgDiagSettingsAll\mgDiagSettingsAll.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\mgDiagSettingsAll.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Create the Azure Management Subscription name
$azManSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azMgmt.ToUpper())

# Get the Management Subscription Alias Id
$azManSubAliasId = Get-AzSubscription -SubscriptionName $azManSubName
$azManagementSubscriptionId = $azManSubAliasId.Id

# Select the Management subscription
Select-AzSubscription -SubscriptionId $azManagementSubscriptionId

# Get the Log Analytics workspace Resource ID
$azLawRgName = ("{0}-RG-MGT-LOG" -f $azAzureUk.ToUpper())
$azLawName = ("{0}-{1}-MGT-01" -f $azAzureUk.ToUpper(),$azLawAbbrName.ToUpper())
$azLaw = Get-AzOperationalInsightsWorkspace -ResourceGroupName $azLawRgName `
                                            -Name $azLawName

$azLawRedId = $azLaw.ResourceId

# Registering 'Microsoft.Insights' resource provider on the Management subscription
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

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName          = 'alz-MGDiagnosticSettings-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  Location                = $azLocation
  ManagementGroupId       = $azTopLevelMGPrefix
  TemplateFile            = $azTemplateFile
  TemplateParameterFile   = $azTemplateParameterFile
  parLogAnalyticsWorkspaceResourceId = $azLawRedId
  WhatIf                  = $WhatIfEnabled
  Verbose                 = $true
}

New-AzManagementGroupDeployment @inputObject
