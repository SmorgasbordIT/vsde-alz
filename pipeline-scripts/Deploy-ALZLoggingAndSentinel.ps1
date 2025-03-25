param (
  [Parameter()]
  [String]$azUk = "$($env:AZUREUK)",

  [Parameter()]
  [String]$azSnk = "$($env:SPACENK_ABBR)",

  [Parameter()]
  [String]$azEnvHub = "$($env:ENV_HUB)",

  [Parameter()]
  [String]$azMgmt = "$($env:MAN_GRP_NAME)",

  [Parameter()]
  [String]$azTemplateFile = "upstream-releases\$($env:UPSTREAM_RELEASE_VERSION)\infra-as-code\bicep\modules\logging\logging.bicep",

  [Parameter()]
  [String]$azTemplateParameterFile = "config\custom-parameters\logging.parameters.all.bicepparam",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Create the Azure Management Subscription name
$azManSubName = ('{0}-{1}-{2}-{3}-01' -f $azUk.ToUpper(),$azSnk.ToUpper(),$azEnvHub.ToUpper(),$azMgmt.ToUpper())

# Create the Logging RG Name
$azLoggingResourceGroup = ("{0}-RG-MGT-LOG" -f $azUk.ToUpper())

# Get the Management Subscription Alias Id
$azManSubAliasId = Get-AzSubscription -SubscriptionName $azManSubName
$azManagementSubscriptionId = $azManSubAliasId.Id

# Registering 'Microsoft.Automation' resource provider on the Management subscription
$azProviders = @('Microsoft.Automation')

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
  DeploymentName        = 'alz-LoggingDeploy-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  ResourceGroupName     = $azLoggingResourceGroup
  TemplateFile          = $azTemplateFile
  TemplateParameterFile = $azTemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $azManagementSubscriptionId

New-AzResourceGroupDeployment @inputObject
