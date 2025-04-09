using '../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/logging/logging.bicep'

// Read in common environment variables for module.

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varAzUkSouth = readEnvironmentVariable('AZ_UKSOUTH','')
var varLogAnalyticsAbbrName = readEnvironmentVariable('LOG_ANALYTICS_ABBR_NAME','LAW')

param parLogAnalyticsWorkspaceName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-${varLogAnalyticsAbbrName}-MGT-01')
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

param parDataCollectionRuleVMInsightsName = toLower('${varAzUkAbbrName}${varAzUkSouth}-dcr-ama-vmi-01')

param parDataCollectionRuleChangeTrackingName= toLower('${varAzUkAbbrName}${varAzUkSouth}-dcr-ama-ct-01')

param parDataCollectionRuleMDFCSQLName = toLower('${varAzUkAbbrName}${varAzUkSouth}-dcr-ama-mdfcsql-01')

param parUserAssignedManagedIdentityName = toLower('${varAzUkAbbrName}${varAzUkSouth}-umi-mgt-${varLogAnalyticsAbbrName}-01')

param parAutomationAccountEnabled = true

param parLogAnalyticsWorkspaceLinkAutomationAccount = true

// Need location formatted without spaces for private DNS zone names.
param parAutomationAccountName = toLower('${varAzUkAbbrName}${varAzUkSouth}-AAA-MGT-${varLogAnalyticsAbbrName}-01')

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

param parTelemetryOptOut = true

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
