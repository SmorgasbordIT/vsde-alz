using '../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/policy/definitions/customPolicyDefinitions.bicep'

param parTargetManagementGroupId = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

param parTelemetryOptOut = true
