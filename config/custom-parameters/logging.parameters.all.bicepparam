using '../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/logging/logging.bicep'

// Read in common environment variables for module.

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varSnk = readEnvironmentVariable('SPACENK_ABBR','snk')
var varLogAnalyticsAbbrName = readEnvironmentVariable('LOG_ANALYTICS_ABBR_NAME','LAW')

param parLogAnalyticsWorkspaceName = toUpper('${varAzUkAbbrName}-${varLogAnalyticsAbbrName}-MGT-01')
param parLogAnalyticsWorkspaceLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

param parAutomationAccountLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

// Need location formatted without spaces for private DNS zone names.
//var varLocationFormatted = toLower(replace(parLogAnalyticsWorkspaceLocation,' ', ''))

param parLogAnalyticsWorkspaceSkuName = 'PerGB2018'
param parLogAnalyticsWorkspaceCapacityReservationLevel = 100
param parLogAnalyticsWorkspaceLogRetentionInDays = 365

param parLogAnalyticsWorkspaceSolutions = [
  'SecurityInsights'
]

param parDataCollectionRuleVMInsightsName = toLower('${varSnk}-ama-vmi-dcr')

param parDataCollectionRuleChangeTrackingName= toLower('${varSnk}-ama-ct-dcr')

param parDataCollectionRuleMDFCSQLName = toLower('${varSnk}-ama-mdfcsql-dcr')

param parUserAssignedManagedIdentityName = toLower('${varAzUkAbbrName}-${varLogAnalyticsAbbrName}-mi-01')

param parAutomationAccountEnabled = true

param parLogAnalyticsWorkspaceLinkAutomationAccount = true

// Need location formatted without spaces for private DNS zone names.
param parAutomationAccountName = toLower('${varAzUkAbbrName}-AAA-MGT-01')

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
