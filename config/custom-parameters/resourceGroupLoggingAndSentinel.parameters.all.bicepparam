using '../../upstream-releases/v0.20.2/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep'

param parLocation = readEnvironmentVariable('LOCATION','uksouth')

var varAzTopLevelMgPrefixName = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

param parResourceGroupName = toUpper('${varAzTopLevelMgPrefixName}-rg-mgt-log')

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
