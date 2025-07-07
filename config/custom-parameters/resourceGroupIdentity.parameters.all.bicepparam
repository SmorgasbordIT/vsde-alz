using '../../bicep/v0.00.4/modules/multipleResourceGroups/multipleResourceGroups.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varAzUkSouth = readEnvironmentVariable('AZ_UKSOUTH','')
var varAzEnvironmentId = readEnvironmentVariable('ID_GRP_NAME','')

// ALZ Identity formatted for Env var
var varIdFormatted = toUpper(substring(varAzEnvironmentId, 0, 2))

var varRgNameNetwork01 = toUpper('${varAzUkAbbrName}${varAzUkSouth}-rg-${varIdFormatted}-network-01')

param parResourceGroupNames = [
  {
    name: varRgNameNetwork01
  }
]

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Identity'
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
