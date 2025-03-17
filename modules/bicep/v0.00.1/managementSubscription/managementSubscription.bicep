targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Management Subscription module'
metadata description = 'Module used to create the management subscriptions in management groups'

@sys.description('Management group Id for the subscription.')
param parManagementGroupId string = ''

@sys.description('Identity group Id for the subscription.')
param parIdentityGroupId string = ''

/*
@sys.description('Connectivity group Id for the subscription.')
param parConnectivityGroupId string = ''
*/

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(8)
@maxLength(51)
param parSnkSubsMgtAliasName string = 'Management'

@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(8)
@maxLength(51)
param parSnkSubsIdenAliasName string = 'Identity'

/*
@sys.description('Provide a name for the alias. This name will also be the display name of the subscription.')
@minLength(8)
@maxLength(51)
param parSnkSubsConnAliasName string = 'Connectivity'
*/

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
        tags: {
          Environment: 'Management'
        }
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
/*
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
*/
// Output Management Subscription Names
output outSnkSubsManagementAliasName string = resSnkSubsMgtAlias.name

// Output Management Subscription Id
output outSnkSubsManagementAliasSubsId string = resSnkSubsMgtAlias.properties.subscriptionId

// Output Identity Subscription Names
output outSnkSubsIdentityAliasName string = resSnkSubsIdenAlias.name

// Output Identity Subscription Id
output outSnkSubsIdentityAliasSubsId string = resSnkSubsIdenAlias.properties.subscriptionId

/*
// Output Connectivity Subscription Names
output outSnkSubsConnectivityAliasName string = resSnkSubsConnAlias.name

// Output Connectivity Subscription Id
output outSnkSubsConnectivityAliasSubsId string = resSnkSubsConnAlias.properties.subscriptionId
*/
