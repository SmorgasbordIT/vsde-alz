using '../../bicep/v0.00.3/modules/policy/assignments/alzDefaults/alzDefaultPolicyAssignments.bicep'

// Default is true, set to false in "Platform only" subscription scenario.
param parPlatformMgAlzDefaultsEnable = true

// Default is true for Alz-Bicep implementations, creates corp and online child Mgs under landingzone mg..
param parLandingZoneChildrenMgAlzDefaultsEnable = true

// Default is false for Alz-Bicep implementations.
param parLandingZoneMgConfidentialEnable = false

// Read in common environment variables for module.
param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')
param parLogAnalyticsWorkSpaceAndAutomationAccountLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')
var varLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varLogAnalyticsAbbrName = readEnvironmentVariable('LOG_ANALYTICS_ABBR_NAME','LAW')
var varLogAnalyticsWorkspaceName = toUpper('${varAzUkAbbrName}-${varLogAnalyticsAbbrName}-MGT-01')

// Read environment variables for subscription IDs and resource group names
param parConnectivitySubscriptionId = ''
var varConnectivityResourceGroupName = toUpper('${varAzUkAbbrName}-rg-con-net-01')
param parLoggingSubscriptionId = ''
var varLoggingResourceGroupName = toUpper('${varAzUkAbbrName}-rg-mgt-log-01')

// Use the logging subscription ID if it is set, otherwise use the connectivity subscription ID ("Platform only" scenario)
var varLoggingSubId = !empty(parLoggingSubscriptionId) ? parLoggingSubscriptionId : parConnectivitySubscriptionId

// This is typcally blank in default Alz-Bicep implementation.
param parTopLevelManagementGroupSuffix = ''

param parDdosEnabled = true

param parLogAnalyticsWorkspaceResourceId = '/subscriptions/${varLoggingSubId}/resourcegroups/${varLoggingResourceGroupName}/providers/microsoft.operationalinsights/workspaces/${varLogAnalyticsWorkspaceName}'

param parLogAnalyticsWorkspaceLogRetentionInDays = '365'

param parLogAnalyticsWorkspaceResourceCategory = 'allLogs'

param parDataCollectionRuleVMInsightsResourceId = '/subscriptions/${parLoggingSubscriptionId}/resourceGroups/${varLoggingResourceGroupName}/providers/Microsoft.Insights/dataCollectionRules/${varAzUkAbbrName}-dcr-ama-vmi-01'

param parDataCollectionRuleChangeTrackingResourceId = '/subscriptions/${parLoggingSubscriptionId}/resourceGroups/${varLoggingResourceGroupName}/providers/Microsoft.Insights/dataCollectionRules/${varAzUkAbbrName}-dcr-ama-ct-01'

param parDataCollectionRuleMDFCSQLResourceId = '/subscriptions/${parLoggingSubscriptionId}/resourceGroups/${varLoggingResourceGroupName}/providers/Microsoft.Insights/dataCollectionRules/${varAzUkAbbrName}-dcr-ama-mdfcsql-01'

param parUserAssignedManagedIdentityResourceId = '/subscriptions/${parLoggingSubscriptionId}/resourcegroups/${varLoggingResourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${varAzUkAbbrName}-umi-mgt-${varLogAnalyticsAbbrName}-01'

param parAutomationAccountName = toLower('${varAzUkAbbrName}-AAA-MGT-${varLogAnalyticsAbbrName}-01')

param parMsDefenderForCloudEmailSecurityContact = 'infrastructure@spacenk.com'

param parDdosProtectionPlanId = ''

param parPrivateDnsResourceGroupId = '/subscriptions/${parConnectivitySubscriptionId}/resourceGroups/${varConnectivityResourceGroupName}'

param parPrivateDnsZonesLocation = varLocation
                                     
param parPrivateDnsZonesNamesToAuditInCorp = []

param parDisableAlzDefaultPolicies = false

param parVmBackupExclusionTagName = ''

param parVmBackupExclusionTagValue = []

param parExcludedPolicyAssignments = []

param parTelemetryOptOut = false
