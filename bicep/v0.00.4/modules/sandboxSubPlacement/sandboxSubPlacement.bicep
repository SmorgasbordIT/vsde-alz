targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Management Subscription module'
metadata description = 'Module used to create the sandbox subscriptions in management groups'

@sys.description('Azure Region where Resource Group will be created.')
param parLocation string

@sys.description('Sandbox group Id for the subscription.')
param parManagementGroupId string = ''

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(5)
@maxLength(51)
param parSubscriptionAliasName string = 'Sandbox'

@sys.description('List of Subscription variables')
param parSubscriptions array = []

@allowed([
  'Production'
  'DevTest'
])
@sys.description('Provide a name for the workload. The workload type of the subscription.')
param parWorkload string = 'Production'

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

module modSubscriptions '../subscriptions/subscriptions.bicep' = [for subscription in parSubscriptions: {
  name: 'deploy-${subscription.SubscriptionAliasName}'
  params: {
    parLocation: parLocation
    parManagementGroupId: parManagementGroupId
    parSubscriptionAliasName: subscription.SubscriptionAliasName
    parWorkload: parWorkload
    parDisplayName: subscription.SubscriptionAliasName
    parBillingScope: subscription.BillingScope
    parTags: parTags
  }
}]

// Output Management Subscription Names
output outSnkSubsSandboxAliasName array = [for subscription in parSubscriptions: subscription.SubscriptionAliasName]
