targetScope = 'subscription'

metadata name = 'ALZ Bicep - Resource Group creation module'
metadata description = 'Module used to create Resource Groups for Azure Landing Zones'

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. The lock settings of the service.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')

  @description('Optional. Notes about this lock.')
  notes: string?
}

@sys.description('Azure Region where Resource Group will be created.')
param parLocation string

@sys.description('Name of Resource Group to be created.')
param parResourceGroupNames array

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

@sys.description('''Resource Lock Configuration for Resource Groups.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parResourceLockConfig lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Resource Group Module.'
}

module modResourceGroups '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep' = [for resResourceGroup in parResourceGroupNames: {
  name: 'deploy-${resResourceGroup.name}'
  params:{
    parResourceGroupName: resResourceGroup.name
    parLocation: parLocation
    parTags: parTags
  }
}]

output outResourceGroupsNames array = [for resResourceGroup in parResourceGroupNames: resResourceGroup.name]
