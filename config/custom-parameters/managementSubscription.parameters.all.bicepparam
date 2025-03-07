using '../../config/custom-modules/azManagementSubscription/managementSubscription.bicep'

param parSnkSubsMgtAliasName = 'Managemen1'

param parSnkSubsIdenAliasName = 'Identity1'

param parSnkSubsConnAliasName = 'Connectivity1'

param parSnkWorkload = 'Production'

// Read environment variables for Management Group ID
var varManagementGroupId = readEnvironmentVariable('MANAGEMENT_GROUP_ID','')

param parManagementGroupId = '/providers/Microsoft.Management/managementGroups/${varManagementGroupId}'

// Read environment variables for Identity Group ID
var varIdentityGroupId = readEnvironmentVariable('IDENTITY_GROUP_ID','')

param parIdentityGroupId = '/providers/Microsoft.Management/managementGroups/${varIdentityGroupId}'

// Read environment variables for Connectivity Group ID
var varConnectivityGroupId = readEnvironmentVariable('CONNECTIVITY_GROUP_ID','')

param parConnectivityGroupId = '/providers/Microsoft.Management/managementGroups/${varConnectivityGroupId}'

// Read environment variables for Billing Scope
var varBillingAccountName = readEnvironmentVariable('BILLING_ACCOUNT_NAME','')
var varBillingProfileName = readEnvironmentVariable('BILLING_PROFILE_NAME','')
var varInvoiceSectionName = readEnvironmentVariable('INVOICE_SECTION_NAME','')

param parSnkBillingScope = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountName}/billingProfiles/${varBillingProfileName}/invoiceSections/${varInvoiceSectionName}'
