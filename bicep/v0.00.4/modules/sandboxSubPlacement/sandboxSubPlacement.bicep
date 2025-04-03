targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Management Subscription module'
metadata description = 'Module used to create the sandbox subscriptions in management groups'

@sys.description('Sandbox group Id for the subscription.')
param parSandboxGroupId string = ''

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(5)
@maxLength(51)
param parSnkSubsSndAliasName string = 'Sandbox'

@allowed([
  'Production'
  'DevTest'
])
@sys.description('Provide a name for the workload. The workload type of the subscription.')
param parSnkWorkload string = 'DevTest'

@sys.description('Provide the full resource ID of billing scope to use for subscription creation.')
param parSnkBillingScope string = ''

resource resSnkSubsSndAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: parSnkSubsSndAliasName
  properties: {
      additionalProperties: {
        managementGroupId: parSandboxGroupId
      }
    workload: parSnkWorkload
    displayName: parSnkSubsSndAliasName
    billingScope: parSnkBillingScope
  }
}

// Output Management Subscription Names
output outSnkSubsSandboxAliasName string = resSnkSubsSndAlias.name

// Output Management Subscription Id
output outSnkSubsSandboxAliasSubsId string = resSnkSubsSndAlias.properties.subscriptionId
