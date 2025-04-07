using '../../bicep/v0.00.4/modules/multipleResourceGroups/multipleResourceGroups.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varAzUks = readEnvironmentVariable('AZ_UKSOUTH','')
var varSnd   = readEnvironmentVariable('ENV_SANDBOX','')
var varEng   = readEnvironmentVariable('ENG_ABBR','')

var varRgNameInfra01 = '${varAzUkAbbrName}${varAzUks}-RG-${varSnd}-${varEng}-JMoore-01'
var varRgNameInfra02 = '${varAzUkAbbrName}${varAzUks}-RG-${varSnd}-${varEng}-AGrobier-01'
var varRgNameInfra03 = '${varAzUkAbbrName}${varAzUks}-RG-${varSnd}-${varEng}-PByrne-01'

param parResourceGroupNames = [
  {
    name: varRgNameInfra01
  }
  {
    name: varRgNameInfra02
  }
  {
    name: varRgNameInfra03
  }
]

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
