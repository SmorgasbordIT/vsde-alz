using '../../upstream-releases/v0.21.0/infra-as-code/bicep/modules/customRoleDefinitions/customRoleDefinitions.bicep'

param parAssignableScopeManagementGroupId = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

param parTelemetryOptOut = false
