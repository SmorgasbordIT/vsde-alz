using '../../bicep/v0.00.4/orchestration/mgDiagSettingsAll/mgDiagSettingsAll.bicep'

var varEnv = readEnvironmentVariable('VAR_ENV','')
param parEnv = toLower(varEnv) == 'nonprd' ? 'nonprd' : 'prd'

var varAlzEnv1 = readEnvironmentVariable('ALZ_ENV1','corp')
param parAlzEnv1 = toLower(varAlzEnv1) == 'development' ? 'development' : 'corp'
var varAlzEnv2 = readEnvironmentVariable('ALZ_ENV2','online')
param parAlzEnv2 = toLower(varAlzEnv2) == 'staging' ? 'staging' : 'online'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')
/*
// Read in common environment variables for module.
var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varLogAnalyticsAbbrName = readEnvironmentVariable('LOG_ANALYTICS_ABBR_NAME','LAW')

var varConnectivitySubscriptionId = readEnvironmentVariable('CONNECTIVITY_SUBSCRIPTION_ID','00000000-0000-0000-0000-000000000000')
var varLoggingSubscriptionId = readEnvironmentVariable('MANAGEMENT_SUBSCRIPTION_ID','00000000-0000-0000-0000-000000000000')
var varLoggingResourceGroupName = toUpper('${varAzUkAbbrName}-rg-mgt-log')
var varLogAnalyticsWorkspaceName = toUpper('${varAzUkAbbrName}-${varLogAnalyticsAbbrName}-MGT-01')

// Use the logging subscription ID if it is set, otherwise use the connectivity subscription ID ("Platform only" scenario)
var varLoggingSubId = !empty(varLoggingSubscriptionId) ? varLoggingSubscriptionId : varConnectivitySubscriptionId
*/
param parTopLevelManagementGroupSuffix = ''

// Set to true by default to deploy diagnostic settings to corp and online child management groups.
param parLandingZoneMgAlzDefaultsEnable = true

// Set to true by default, set to False if using "Platform only" scenario.
param parPlatformMgAlzDefaultsEnable = true

param parLandingZoneMgConfidentialEnable = false

param parLogAnalyticsWorkspaceResourceId = ''

param parDiagnosticSettingsName = 'toLaws'

param parLandingZoneMgChildren = []

param parPlatformMgChildren = []

param parTelemetryOptOut = true
