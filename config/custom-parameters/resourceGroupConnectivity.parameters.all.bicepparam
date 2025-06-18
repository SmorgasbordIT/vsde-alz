using '../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varAzUkSouth = readEnvironmentVariable('AZ_UKSOUTH','')

param parResourceGroupName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-rg-conn-vnet-01')

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Connectivity'
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
