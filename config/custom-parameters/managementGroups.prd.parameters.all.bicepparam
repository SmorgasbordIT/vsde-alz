using '../../bicep/v0.00.4/modules/managementGroups/managementGroups.bicep'

// Parameters for Production Management Groups deployment
param parDeploymentEnvironment = 'Production'

// Parameter to specify the environment type for the Management Group ID.
param parDeployEnv = 'prd'

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
  'prd-corp': {
    displayName: 'Corp'
  }
  'prd-online': {
    displayName: 'Online'
  }
}

// Typically blank in default Alz-Bicep deployments
// Use to specify custom management group names under Platform mg.
param parPlatformMgChildren = {
  'prd-connectivity': {
    displayName: 'Connectivity'
  }
  'prd-identity': {
    displayName: 'Identity'
  }
  'prd-management': {
    displayName: 'Management'
  }
  'prd-shared': {
    displayName: 'Shared'
  }
}

param parTelemetryOptOut = true
