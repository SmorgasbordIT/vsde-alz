using '../../bicep/v0.00.4/modules/multipleResourceGroups/multipleResourceGroups.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varAzUkSouth = readEnvironmentVariable('AZ_UKSOUTH','')

var varRgNameNetworkt01 = toUpper('${varAzUkAbbrName}${varAzUkSouth}-rg-conn-network-01')
var varRgNameSecuriyt01 = toUpper('${varAzUkAbbrName}${varAzUkSouth}-rg-conn-security-01')
var varRgNameDns01      = toUpper('${varAzUkAbbrName}${varAzUkSouth}-rg-conn-dns-01')

param parResourceGroupNames = [
  {
    name: varRgNameNetworkt01
  }
  {
    name: varRgNameSecuriyt01
  }
  {
    name: varRgNameDns01
  }
]

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Hub'
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
