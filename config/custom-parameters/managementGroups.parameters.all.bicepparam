/* 
  managementGroups.parameters.all.bicepparam
  Author: J Davis
  Date: 2025-02-17
  Version: 1.0
  
  This file contains the parameters for the managementGroups.bicep file, and replaces the json version
  used in the original ALZ-Bicep implementation. Commonly used parameters are read from the .env file 
  which is parsed during pipeline deployment.

*/

using '../../modules/bicep/v0.00.1/managementGroups/managementGroups.bicep'

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('azTOP_LEVEL_MG_PREFIX','azuk-snk')

// Typically blank in default Alz-Bicep deployments
param parTopLevelManagementGroupSuffix = ''

param parTopLevelManagementGroupDisplayName = 'AZUK SNK'

// To deploy to existing intermediate management group, set the parent ID here, otherwise leave blank for default Alz-Bicep deployment.
param parTopLevelManagementGroupParentId = ''

// True for default Alz-Bicep deployments.
param parLandingZoneMgAlzDefaultsEnable = true

// True for default Alz-Bicep deployments. 
// Default is true for Alz-Bicep default deployment, set to false for "Platform only" scenarios. (no separate connectivity, identity, or management subscriptions.)
param parPlatformMgAlzDefaultsEnable = true

// Typically false in default Alz-Bicep deployments.
param parLandingZoneMgConfidentialEnable = false

// Typically blank in default Alz-Bicep deployments
// Use to specify custom management group names under Landing Zone mg.
param parLandingZoneMgChildren = {}

// Typically blank in default Alz-Bicep deployments
// Use to specify custom management group names under Platform mg.
param parPlatformMgChildren = {}

param parTelemetryOptOut = false
