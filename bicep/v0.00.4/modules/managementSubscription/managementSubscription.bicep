targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Management Subscription module'
metadata description = 'Module used to create the management subscriptions in management groups'

@sys.description('Management group Id for the subscription.')
param parManagementGroupId string = ''

@sys.description('Identity group Id for the subscription.')
param parIdentityGroupId string = ''

@sys.description('Connectivity group Id for the subscription.')
param parConnectivityGroupId string = ''

@sys.description('Shared Services group Id for the subscription.')
param parSharedGroupId string = ''

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(5)
@maxLength(51)
param parSnkSubsMgtAliasName string = 'Management'

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(5)
@maxLength(51)
param parSnkSubsIdenAliasName string = 'Identity'

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(5)
@maxLength(51)
param parSnkSubsConnAliasName string = 'Connectivity'

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(5)
@maxLength(51)
param parSnkSubsShrAliasName string = 'Shared'

@allowed([
  'Production'
  'DevTest'
])
@sys.description('Provide a name for the workload. The workload type of the subscription.')
param parSnkWorkload string = 'Production'

@sys.description('Provide the full resource ID of billing scope to use for subscription creation.')
param parSnkBillingScope string = ''

resource resSnkSubsMgtAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: parSnkSubsMgtAliasName
  properties: {
      additionalProperties: {
        managementGroupId: parManagementGroupId
      }
    workload: parSnkWorkload
    displayName: parSnkSubsMgtAliasName
    billingScope: parSnkBillingScope
  }
}

resource resSnkSubsIdenAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: parSnkSubsIdenAliasName
  properties: {
      additionalProperties: {
        managementGroupId: parIdentityGroupId
      }
    workload: parSnkWorkload
    displayName: parSnkSubsIdenAliasName
    billingScope: parSnkBillingScope
  }
}

resource resSnkSubsConnAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: parSnkSubsConnAliasName
  properties: {
      additionalProperties: {
        managementGroupId: parConnectivityGroupId
      }
    workload: parSnkWorkload
    displayName: parSnkSubsConnAliasName
    billingScope: parSnkBillingScope
  }
}

resource resSnkSubsShrAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: parSnkSubsShrAliasName
  properties: {
      additionalProperties: {
        managementGroupId: parSharedGroupId
      }
    workload: parSnkWorkload
    displayName: parSnkSubsShrAliasName
    billingScope: parSnkBillingScope
  }
}

// Output Management Subscription Names
output outSnkSubsManagementAliasName string = resSnkSubsMgtAlias.name

// Output Management Subscription Id
output outSnkSubsManagementAliasSubsId string = resSnkSubsMgtAlias.properties.subscriptionId

// Output Identity Subscription Names
output outSnkSubsIdentityAliasName string = resSnkSubsIdenAlias.name

// Output Identity Subscription Id
output outSnkSubsIdentityAliasSubsId string = resSnkSubsIdenAlias.properties.subscriptionId

// Output Connectivity Subscription Names
output outSnkSubsConnectivityAliasName string = resSnkSubsConnAlias.name

// Output Connectivity Subscription Id
output outSnkSubsConnectivityAliasSubsId string = resSnkSubsConnAlias.properties.subscriptionId

// Output Shared Subscription Names
output outSnkSubsSharedAliasName string = resSnkSubsShrAlias.name

// Output Shared Subscription Id
output outSnkSubsSharedAliasSubsId string = resSnkSubsShrAlias.properties.subscriptionId
