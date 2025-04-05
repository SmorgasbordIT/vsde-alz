using '../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varAzUks = readEnvironmentVariable('AZ_UKSOUTH','')
var varSnd = readEnvironmentVariable('ENV_SANDBOX','')

param parResourceGroupName = toUpper('${varAzUkAbbrName}${varAzUks}-rg-${varSnd}-jd-01')

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Sandbox'
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
