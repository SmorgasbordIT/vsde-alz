using '../../bicep/v0.00.4/modules/managementGroups/managementGroups.bicep'

// Parameters for NonProduction Management Groups deployment
param parDeploymentEnvironment = 'NonProduction'

// Parameter to specify the environment type for the Management Group ID.
param parDeployEnv = 'nonprd' 

param parTopLevelManagementGroupPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-sbit')

// Typically blank in default Alz-Bicep deployments
param parTopLevelManagementGroupSuffix = ''

param parTopLevelManagementGroupDisplayName = 'AZUK SBIT'

// To deploy to existing intermediate management group, set the parent ID here, otherwise leave blank for default Alz-Bicep deployment.
param parTopLevelManagementGroupParentId = ''

// True for default Alz-Bicep deployments.
param parLandingZoneMgAlzDefaultsEnable = false

// True for default Alz-Bicep deployments. 
// Default is true for Alz-Bicep default deployment, set to false for "Platform only" scenarios. (no separate connectivity, identity, or management subscriptions.)
param parPlatformMgAlzDefaultsEnable = false

// Typically false in default Alz-Bicep deployments.
param parLandingZoneMgConfidentialEnable = false

// Typically blank in default Alz-Bicep deployments
// Use to specify custom management group names under Landing Zone mg.
param parLandingZoneMgChildren = {
  'nonprd-development': {
    displayName: 'Development'
  }
  'nonprd-staging': {
    displayName: 'Staging'
  }
}

// Typically blank in default Alz-Bicep deployments
// Use to specify custom management group names under Platform mg.
param parPlatformMgChildren = {
  'nonprd-connectivity': {
    displayName: 'Connectivity'
  }
  'nonprd-identity': {
    displayName: 'Identity'
  }
  'nonprd-management': {
    displayName: 'Management'
  }
  'nonprd-shared': {
    displayName: 'Shared'
  }
}

param parTelemetryOptOut = true
