/* 
  managementSubscription.parameters.all.bicepparam
  Author: J Davis
  Date: 2025-02-17
  Version: 1.0
  
  This file contains the parameters for the managementSubscription.bicep file, and replaces the json version
  used in the original ALZ-Bicep implementation. Commonly used parameters are read from the .env file 
  which is parsed during pipeline deployment.

*/

using '../../modules/bicep/v0.00.1/managementSubscription/managementSubscription.bicep'

var varAzEnvironmentHub = readEnvironmentVariable('ENV_HUB','')

var varAzLocationAreviation = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','')

param parSnkSubsMgtAliasName = toUpper('${varAzLocationAreviation}-${varAzEnvironmentHub}-Management-01')
param parSnkSubsIdenAliasName = toUpper('${varAzLocationAreviation}-${varAzEnvironmentHub}-Identity-01')
param parSnkSubsConnAliasName = toUpper('${varAzLocationAreviation}-${varAzEnvironmentHub}-Connectivity-01')

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
var varBillingAccountName = readEnvironmentVariable('INFRA_BILLING_ACCOUNT_NAME','')
var varBillingProfileName = readEnvironmentVariable('INFRA_02_BILLING_PROFILE_NAME','')
var varInvoiceSectionName = readEnvironmentVariable('INFRA_OPEX_INVOICE_SECTION_NAME','')

param parSnkBillingScope = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountName}/billingProfiles/${varBillingProfileName}/invoiceSections/${varInvoiceSectionName}'
