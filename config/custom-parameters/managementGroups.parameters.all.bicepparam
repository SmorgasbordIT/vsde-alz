using '../../bicep/v0.00.4/modules/managementGroups/managementGroups.bicep'

// Parameters for NonProduction Management Groups deployment
param parDeploymentEnvironment = 'NonProduction'

// Parameter to specify the environment type for the Management Group ID.
var varEnv = readEnvironmentVariable('VAR_ENV','')
param parEnv = toLower(varEnv) == 'nonprd' ? 'nonprd' : 'prd'

var varAlzEnv1 = readEnvironmentVariable('ALZ_ENV1','Corp')
param parAlzEnv1 = toLower(varAlzEnv1) == 'development' ? 'development' : 'corp'
var varAlzEnv2 = readEnvironmentVariable('ALZ_ENV2','Online')
param parAlzEnv2 = toLower(varAlzEnv2) == 'staging' ? 'staging' : 'online'

var varPlatHub = readEnvironmentVariable('CONN_GRP_NAME','Connectivity')
param parPlatHub = toLower(varPlatHub)

var varPlatId = readEnvironmentVariable('ID_GRP_NAME','Identity')
param parPlatId = toLower(varPlatId)

var varPlatMgt = readEnvironmentVariable('MAN_GRP_NAME','Management')
param parPlatMgt = toLower(varPlatMgt)

var varPlatShr = readEnvironmentVariable('SHR_GRP_NAME','Shared')
param parPlatShr = toLower(varPlatShr)

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
  '${parEnv}-${parAlzEnv1}': {
    displayName: varAlzEnv1
  }
  '${parEnv}-${parAlzEnv2}': {
    displayName: varAlzEnv2
  }
}

// Typically blank in default Alz-Bicep deployments
// Use to specify custom management group names under Platform mg.
param parPlatformMgChildren = {
  '${parEnv}-${parPlatHub}': {
    displayName: varPlatHub
  }
  '${parEnv}-${parPlatId}': {
    displayName: varPlatId
  }
  '${parEnv}-${parPlatMgt}': {
    displayName: varPlatMgt
  }
  '${parEnv}-${parPlatShr}': {
    displayName: varPlatShr
  }
}

param parTelemetryOptOut = true
