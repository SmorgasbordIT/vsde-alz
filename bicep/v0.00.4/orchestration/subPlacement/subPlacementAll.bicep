targetScope = 'managementGroup'

metadata name = 'ALZ Bicep orchestration - Subscription Placement - ALL'
metadata description = 'Orchestration module that helps to define where all Subscriptions should be placed in the ALZ Management Group Hierarchy'

@sys.description('What environment is this deployment for? Default: nonprd')
@secure()
param parEnv string = ''

@sys.description('Prefix used for the management group hierarchy.')
@minLength(2)
@maxLength(15)
param parTopLevelManagementGroupPrefix string = 'alz'

@sys.description('Optional suffix for the management group hierarchy. This suffix will be appended to management group names/IDs. Include a preceding dash if required. Example: -suffix')
@maxLength(10)
param parTopLevelManagementGroupSuffix string = ''

@sys.description('An array of Subscription IDs to place in the Intermediate Root Management Group. Default: Empty Array')
param parIntRootMgSubs array = []

@sys.description('An array of Subscription IDs to place in the Platform Management Group. Default: Empty Array')
param parPlatformMgSubs array = []

@sys.description('An array of Subscription IDs to place in the (Platform) Management Management Group. Default: Empty Array')
param parPlatformManagementMgSubs array = []

@sys.description('An array of Subscription IDs to place in the (Platform) Connectivity Management Group. Default: Empty Array')
param parPlatformConnectivityMgSubs array = []

@sys.description('Dictionary Object to allow additional or different child Management Groups of the Platform Management Group describing the Subscription IDs which each of them contain. Default: Empty Object')
param parPlatformMgChildrenSubs object = {}

@sys.description('An array of Subscription IDs to place in the (Platform) Identity Management Group. Default: Empty Array')
param parPlatformIdentityMgSubs array = []

@sys.description('An array of Subscription IDs to place in the Landing Zones Management Group. Default: Empty Array')
param parLandingZonesMgSubs array = []

@sys.description('An array of Subscription IDs to place in the Corp (Landing Zones) Management Group. Default: Empty Array')
param parLandingZonesCorpMgSubs array = []

@sys.description('An array of Subscription IDs to place in the Online (Landing Zones) Management Group. Default: Empty Array')
param parLandingZonesOnlineMgSubs array = []

@sys.description('An array of Subscription IDs to place in the Confidential Corp (Landing Zones) Management Group. Default: Empty Array')
param parLandingZonesConfidentialCorpMgSubs array = []

@sys.description('An array of Subscription IDs to place in the Confidential Online (Landing Zones) Management Group. Default: Empty Array')
param parLandingZonesConfidentialOnlineMgSubs array = []

@sys.description('Dictionary Object to allow additional or different child Management Groups of the Landing Zones Management Group describing the Subscription IDs which each of them contain. Default: Empty Object')
param parLandingZoneMgChildrenSubs object = {}

@sys.description('An array of Subscription IDs to place in the Decommissioned Management Group. Default: Empty Array')
param parDecommissionedMgSubs array = []

@sys.description('An array of Subscription IDs to place in the Sandbox Management Group. Default: Empty Array')
param parSandboxMgSubs array = []

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

var varMgIds = {
  intRoot: '${parTopLevelManagementGroupPrefix}${parTopLevelManagementGroupSuffix}'
  platform: '${parTopLevelManagementGroupPrefix}-plat${parTopLevelManagementGroupSuffix}'
  platformManagement: '${parTopLevelManagementGroupPrefix}-plat-${parEnv}-management${parTopLevelManagementGroupSuffix}'
  platformConnectivity: '${parTopLevelManagementGroupPrefix}-plat-${parEnv}-connectivity${parTopLevelManagementGroupSuffix}'
  platformIdentity: '${parTopLevelManagementGroupPrefix}-plat-${parEnv}-identity${parTopLevelManagementGroupSuffix}'
  landingZones: '${parTopLevelManagementGroupPrefix}-alz${parTopLevelManagementGroupSuffix}'
  landingZonesCorp: '${parTopLevelManagementGroupPrefix}-alz-${parEnv}-development${parTopLevelManagementGroupSuffix}'
  landingZonesOnline: '${parTopLevelManagementGroupPrefix}-alz-${parEnv}-staging${parTopLevelManagementGroupSuffix}'
  landingZonesConfidentialCorp: '${parTopLevelManagementGroupPrefix}-alz-confidential-corp${parTopLevelManagementGroupSuffix}'
  landingZonesConfidentialOnline: '${parTopLevelManagementGroupPrefix}-alz-confidential-online${parTopLevelManagementGroupSuffix}'
  decommissioned: '${parTopLevelManagementGroupPrefix}-decomm${parTopLevelManagementGroupSuffix}'
  sandbox: '${parTopLevelManagementGroupPrefix}-snd${parTopLevelManagementGroupSuffix}'
}

var varDeploymentNames = {
  modIntRootMgSubPlacement: take('modIntRootMgSubPlacement-${uniqueString(varMgIds.intRoot, string(length(parIntRootMgSubs)), deployment().name)}', 64)
  modPlatformMgSubPlacement: take('modPlatformMgSubPlacement-${uniqueString(varMgIds.platform, string(length(parPlatformMgSubs)), deployment().name)}', 64)
  modPlatformManagementMgSubPlacement: take('modPlatformManagementMgSubPlacement-${uniqueString(varMgIds.platformManagement, string(length(parPlatformManagementMgSubs)), deployment().name)}', 64)
  modPlatformConnectivityMgSubPlacement: take('modPlatformConnectivityMgSubPlacement-${uniqueString(varMgIds.platformConnectivity, string(length(parPlatformConnectivityMgSubs)), deployment().name)}', 64)
  modPlatformIdentityMgSubPlacement: take('modPlatformIdentityMgSubPlacement-${uniqueString(varMgIds.platformIdentity, string(length(parPlatformIdentityMgSubs)), deployment().name)}', 64)
  modLandingZonesMgSubPlacement: take('modLandingZonesMgSubPlacement-${uniqueString(varMgIds.landingZones, string(length(parLandingZonesMgSubs)), deployment().name)}', 64)
  modLandingZonesCorpMgSubPlacement: take('modLandingZonesCorpMgSubPlacement-${uniqueString(varMgIds.landingZonesCorp, string(length(parLandingZonesCorpMgSubs)), deployment().name)}', 64)
  modLandingZonesOnlineMgSubPlacement: take('modLandingZonesOnlineMgSubPlacement-${uniqueString(varMgIds.landingZonesOnline, string(length(parLandingZonesOnlineMgSubs)), deployment().name)}', 64)
  modLandingZonesConfidentialCorpMgSubPlacement: take('modLandingZonesConfidentialCorpMgSubPlacement-${uniqueString(varMgIds.landingZonesConfidentialCorp, string(length(parLandingZonesConfidentialCorpMgSubs)), deployment().name)}', 64)
  modLandingZonesConfidentialOnlineMgSubPlacement: take('modLandingZonesConfidentialOnlineMgSubPlacement-${uniqueString(varMgIds.landingZonesConfidentialOnline, string(length(parLandingZonesConfidentialOnlineMgSubs)), deployment().name)}', 64)
  modDecommissionedMgSubPlacement: take('modDecommissionedMgSubPlacement-${uniqueString(varMgIds.decommissioned, string(length(parDecommissionedMgSubs)), deployment().name)}', 64)
  modSandboxMgSubPlacement: take('modSandboxMgSubPlacement-${uniqueString(varMgIds.sandbox, string(length(parSandboxMgSubs)), deployment().name)}', 64)
}

// Customer Usage Attribution Id
var varCuaid = 'bb800623-86ff-4ab4-8901-93c2b70967ae'

module modIntRootMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parIntRootMgSubs)) {
  name: varDeploymentNames.modIntRootMgSubPlacement
  scope: managementGroup(varMgIds.intRoot)
  params: {
    parTargetManagementGroupId: varMgIds.intRoot
    parSubscriptionIds: parIntRootMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Platform Management Groups
module modPlatformMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parPlatformMgSubs)) {
  name: varDeploymentNames.modPlatformMgSubPlacement
  scope: managementGroup(varMgIds.platform)
  params: {
    parTargetManagementGroupId: varMgIds.platform
    parSubscriptionIds: parPlatformMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

module modPlatformManagementMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parPlatformManagementMgSubs)) {
  name: varDeploymentNames.modPlatformManagementMgSubPlacement
  scope: managementGroup(varMgIds.platformManagement)
  params: {
    parTargetManagementGroupId: varMgIds.platformManagement
    parSubscriptionIds: parPlatformManagementMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

module modplatformConnectivityMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parPlatformConnectivityMgSubs)) {
  name: varDeploymentNames.modPlatformConnectivityMgSubPlacement
  scope: managementGroup(varMgIds.platformConnectivity)
  params: {
    parTargetManagementGroupId: varMgIds.platformConnectivity
    parSubscriptionIds: parPlatformConnectivityMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

module modplatformIdentityMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parPlatformIdentityMgSubs)) {
  name: varDeploymentNames.modPlatformIdentityMgSubPlacement
  scope: managementGroup(varMgIds.platformIdentity)
  params: {
    parTargetManagementGroupId: varMgIds.platformIdentity
    parSubscriptionIds: parPlatformIdentityMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Custom Children Platform Management Groups
module modPlatformMgChildrenSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = [for mg in items(parPlatformMgChildrenSubs): if (!empty(parPlatformMgChildrenSubs)) {
  name: take('modPlatformMgChildrenSubPlacement-${uniqueString(mg.key, string(length(mg.value.subscriptions)), deployment().name)}', 64)
  scope: managementGroup('${parTopLevelManagementGroupPrefix}-${mg.key}${parTopLevelManagementGroupSuffix}')
  params: {
    parTargetManagementGroupId: '${parTopLevelManagementGroupPrefix}-${mg.key}${parTopLevelManagementGroupSuffix}'
    parSubscriptionIds: mg.value.subscriptions
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Landing Zone Management Groups
module modLandingZonesMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parLandingZonesMgSubs)) {
  name: varDeploymentNames.modLandingZonesMgSubPlacement
  scope: managementGroup(varMgIds.landingZones)
  params: {
    parTargetManagementGroupId: varMgIds.landingZones
    parSubscriptionIds: parLandingZonesMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

module modLandingZonesCorpMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parLandingZonesCorpMgSubs)) {
  name: varDeploymentNames.modLandingZonesCorpMgSubPlacement
  scope: managementGroup(varMgIds.landingZonesCorp)
  params: {
    parTargetManagementGroupId: varMgIds.landingZonesCorp
    parSubscriptionIds: parLandingZonesCorpMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

module modLandingZonesOnlineMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parLandingZonesOnlineMgSubs)) {
  name: varDeploymentNames.modLandingZonesOnlineMgSubPlacement
  scope: managementGroup(varMgIds.landingZonesOnline)
  params: {
    parTargetManagementGroupId: varMgIds.landingZonesOnline
    parSubscriptionIds: parLandingZonesOnlineMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Confidential Landing Zone Management Groups
module modLandingZonesConfidentialCorpMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parLandingZonesConfidentialCorpMgSubs)) {
  name: varDeploymentNames.modLandingZonesConfidentialCorpMgSubPlacement
  scope: managementGroup(varMgIds.landingZonesConfidentialCorp)
  params: {
    parTargetManagementGroupId: varMgIds.landingZonesConfidentialCorp
    parSubscriptionIds: parLandingZonesConfidentialCorpMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

module modLandingZonesConfidentialOnlineMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parLandingZonesConfidentialOnlineMgSubs)) {
  name: varDeploymentNames.modLandingZonesConfidentialOnlineMgSubPlacement
  scope: managementGroup(varMgIds.landingZonesConfidentialOnline)
  params: {
    parTargetManagementGroupId: varMgIds.landingZonesConfidentialOnline
    parSubscriptionIds: parLandingZonesConfidentialOnlineMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Custom Children Landing Zone Management Groups
module modLandingZonesMgChildrenSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = [for mg in items(parLandingZoneMgChildrenSubs): if (!empty(parLandingZoneMgChildrenSubs)) {
  name: take('modLandingZonesMgChildrenSubPlacement-${uniqueString(mg.key, string(length(mg.value.subscriptions)), deployment().name)}', 64)
  scope: managementGroup('${parTopLevelManagementGroupPrefix}-alz-${mg.key}${parTopLevelManagementGroupSuffix}')
  params: {
    parTargetManagementGroupId: '${parTopLevelManagementGroupPrefix}-alz-${mg.key}${parTopLevelManagementGroupSuffix}'
    parSubscriptionIds: mg.value.subscriptions
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Decommissioned Management Group
module modDecommissionedMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parDecommissionedMgSubs)) {
  name: varDeploymentNames.modDecommissionedMgSubPlacement
  scope: managementGroup(varMgIds.decommissioned)
  params: {
    parTargetManagementGroupId: varMgIds.decommissioned
    parSubscriptionIds: parDecommissionedMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Sandbox Management Group
module modSandboxMgSubPlacement '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (!empty(parSandboxMgSubs)) {
  name: varDeploymentNames.modSandboxMgSubPlacement
  scope: managementGroup(varMgIds.sandbox)
  params: {
    parTargetManagementGroupId: varMgIds.sandbox
    parSubscriptionIds: parSandboxMgSubs
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/CRML/customerUsageAttribution/cuaIdManagementGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varCuaid}-${uniqueString(deployment().location)}'
  params: {}
}
