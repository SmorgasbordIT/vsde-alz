using '../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/customRoleDefinitions/customRoleDefinitions.bicep'

param parAssignableScopeManagementGroupId = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

param parTelemetryOptOut = false
