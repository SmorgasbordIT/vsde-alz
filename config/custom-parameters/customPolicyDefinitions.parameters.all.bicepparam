using '../../upstream-releases/v0.21.0/infra-as-code/bicep/modules/policy/definitions/customPolicyDefinitions.bicep'

param parTargetManagementGroupId = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

param parTelemetryOptOut = false
