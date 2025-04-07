targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Management Subscription module'
metadata description = 'Module used to create subscriptions in management groups'

@sys.description('Azure Region where Resource Group will be created.')
param parLocation string

@sys.description('Sandbox group Id for the subscription.')
param parManagementGroupId string = ''

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(5)
@maxLength(51)
param parSubscriptionAliasName string = 'Sandbox'

@allowed([
  'Production'
  'DevTest'
])
@sys.description('Provide a name for the workload. The workload type of the subscription.')
param parWorkload string = 'Production'

@sys.description('This display name will also be the same name as the subscription alias name.')
param parDisplayName string

@sys.description('Provide the full resource ID of billing scope to use for subscription creation.')
param parBillingScope string

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '3dfa9e81-f0cf-4b25-858e-167937fd380b'

resource resSubscriptionAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: parSubscriptionAliasName
  properties: {
      additionalProperties: {
        managementGroupId: parManagementGroupId
        tags: parTags
      }
    workload: parWorkload
    displayName: parDisplayName
    billingScope: parBillingScope
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/CRML/customerUsageAttribution/cuaIdManagementGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varCuaid}-${uniqueString(deployment().location)}'
  params: {}
}

// Output Management Subscription Names
output outSnkSubsSandboxAliasName string = resSubscriptionAlias.name

// Output Management Subscription Id
output outSnkSubsSandboxAliasSubsId string = resSubscriptionAlias.properties.subscriptionId
