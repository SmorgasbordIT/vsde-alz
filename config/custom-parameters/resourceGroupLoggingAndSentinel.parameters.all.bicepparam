using '../../upstream-releases/v0.20.2/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep'

param parLocation = readEnvironmentVariable('LOCATION','uksouth')

param parResourceGroupName = readEnvironmentVariable('LOGGING_RESOURCE_GROUP','rg-mgt-log')

param parTags = {
  Environment: 'Management'
  DeployedBy: 'Cloud Tech'
  // 'Expiry Date': '2025-02-17'
  // 'Business Unit': 'Tech'
  // 'Owner': 'J Davis'
}

param parTelemetryOptOut = false

param parResourceLockConfig = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep resourceGroup Module'
}
