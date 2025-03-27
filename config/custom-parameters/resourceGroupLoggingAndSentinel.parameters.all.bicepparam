using '../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')

param parResourceGroupName = toUpper('${varAzUkAbbrName}-rg-mgt-log-01')

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Management'
  DeployedBy: 'Cloud Tech'
  CreatedBy: 'jonathan.davis@spacenk.com'
  SvcName: 'Infrastructure'
  SvcOwner: 'Infrastructure@spacenk.com'
}

param parTelemetryOptOut = false

param parResourceLockConfig = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep resourceGroup Module'
}
