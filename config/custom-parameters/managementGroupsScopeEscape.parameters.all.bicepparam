/* 
  managementGroupsScopeEscape.parameters.all.bicepparam
  Author: J Davis
  Date: 2025-02-17
  Version: 1.0
  
  This file contains the parameters for the managementGroupsScopeEscape.bicep file, and replaces the json version
  used in the original ALZ-Bicep implementation. Commonly used parameters are read from the .env file 
  which is parsed during pipeline deployment.

*/

using '../../upstream-releases/v0.20.2/infra-as-code/bicep/modules/managementGroups/managementGroupsScopeEscape.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')
param parTopLevelManagementGroupSuffix = readEnvironmentVariable('TOP_LEVEL_MG_SUFFIX','')
param parTopLevelManagementGroupDisplayName = readEnvironmentVariable('TOP_LEVEL_MG_DISPLAY_NAME','AZUK SNK')
param parTopLevelManagementGroupParentId = ''
param parLandingZoneMgAlzDefaultsEnable = true
param parPlatformMgAlzDefaultsEnable = true
param parLandingZoneMgConfidentialEnable = false
param parLandingZoneMgChildren = {}
param parPlatformMgChildren = {}
param parTelemetryOptOut = false
