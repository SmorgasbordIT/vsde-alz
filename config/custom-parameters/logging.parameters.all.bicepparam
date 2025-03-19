using '../../upstream-releases/v0.21.0/infra-as-code/bicep/modules/logging/logging.bicep'

// Read in common environment variables for module.

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varLogAnalyticsAbbrName = readEnvironmentVariable('LOG_ANALYTICS_ABBR_NAME','LAW')

param parLogAnalyticsWorkspaceName = toUpper('${varAzUkAbbrName}-${varLogAnalyticsAbbrName}-MGT-01')
param parLogAnalyticsWorkspaceLocation = readEnvironmentVariable('LOCATION','uksouth')

param parAutomationAccountLocation = readEnvironmentVariable('LOCATION','uksouth')

// Need location formatted without spaces for private DNS zone names.
//var varLocationFormatted = toLower(replace(parLogAnalyticsWorkspaceLocation,' ', ''))

param parLogAnalyticsWorkspaceSkuName = 'PerGB2018'
param parLogAnalyticsWorkspaceCapacityReservationLevel = 100
param parLogAnalyticsWorkspaceLogRetentionInDays = 365

param parLogAnalyticsWorkspaceSolutions = [
  'SecurityInsights'
]

param parDataCollectionRuleVMInsightsName = 'snk-ama-vmi-dcr'

param parDataCollectionRuleChangeTrackingName= 'snk-ama-ct-dcr'

param parDataCollectionRuleMDFCSQLName = 'snk-ama-mdfcsql-dcr'

param parUserAssignedManagedIdentityName = toLower('${varAzUkAbbrName}-${varLogAnalyticsAbbrName}-mi-01')

param parLogAnalyticsWorkspaceLinkAutomationAccount = true

param parAutomationAccountName = toUpper('${varAzUkAbbrName}-AAA-MGT-01')

param parAutomationAccountUseManagedIdentity = true

param parAutomationAccountPublicNetworkAccess = true

param parTags = {
  Location: ('${parLogAnalyticsWorkspaceLocation}')
  Environment: 'Management'
  DeployedBy: 'Cloud Tech'
  CreatedBy: 'jonathan.davis@spacenk.com'
  SvcName: 'Infrastructure'
  SvcOwner: 'Infrastructure@spacenk.com'
}

param parUseSentinelClassicPricingTiers = false

param parLogAnalyticsLinkedServiceAutomationAccountName = 'Automation'

param parTelemetryOptOut = false

param parGlobalResourceLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Logging Module.'
}

param parAutomationAccountLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Logging Module.'
}

param parLogAnalyticsWorkspaceLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Logging Module.'
}

param parLogAnalyticsWorkspaceSolutionsLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Logging Module.'
}
