/* 
  managementSubscription.parameters.all.bicepparam
  Author: J Davis
  Date: 2025-02-17
  Version: 1.0
  
  This file contains the parameters for the managementSubscription.bicep file, and replaces the json version
  used in the original ALZ-Bicep implementation. Commonly used parameters are read from the .env file 
  which is parsed during pipeline deployment.

*/

using '../../bicep/v0.00.2/modules/managementSubscription/managementSubscription.bicep'

var varAzEnvironmentHub = readEnvironmentVariable('ENV_HUB','')

var varAzLocationAbbr = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','')

var varAzUk = readEnvironmentVariable('AZUREUK','')
var varSnk  = readEnvironmentVariable('SPACENK_ABBR','')
var varPlat = readEnvironmentVariable('PALTFORM_ABBR','')
var varMgmt = readEnvironmentVariable('MAN_GRP_NAME','')
var varId   = readEnvironmentVariable('ID_GRP_NAME','')
var varConn = readEnvironmentVariable('CONN_GRP_NAME','')

param parSnkWorkload = 'Production'

// Read environment variables for Management Group ID
//var varManagementGroupId = readEnvironmentVariable('MANAGEMENT_GROUP_ID','')
var varManagementGroupId = '${varAzUk}-${varSnk}-${varPlat}-${varMgmt}'

param parSnkSubsMgtAliasName  = toUpper('${varAzLocationAbbr}-${varAzEnvironmentHub}-${varMgmt}-01')

param parManagementGroupId = toLower('/providers/Microsoft.Management/managementGroups/${varManagementGroupId}')

// Read environment variables for Identity Group ID
//var varIdentityGroupId = readEnvironmentVariable('IDENTITY_GROUP_ID','')
var varIdentityGroupId = '${varAzUk}-${varSnk}-${varPlat}-${varId}'

param parSnkSubsIdenAliasName = toUpper('${varAzLocationAbbr}-${varAzEnvironmentHub}-${varId}-01')

param parIdentityGroupId = toLower('/providers/Microsoft.Management/managementGroups/${varIdentityGroupId}')

// Read environment variables for Connectivity Group ID
//var varConnectivityGroupId = readEnvironmentVariable('CONNECTIVITY_GROUP_ID','')
var varConnectivityGroupId = '${varAzUk}-${varSnk}-${varPlat}-${varConn}'

param parSnkSubsConnAliasName = toUpper('${varAzLocationAbbr}-${varAzEnvironmentHub}-${varConn}-01')

param parConnectivityGroupId = toLower('/providers/Microsoft.Management/managementGroups/${varConnectivityGroupId}')

// Read environment variables for Billing Scope
var varBillingAccountName = readEnvironmentVariable('INFRA_BILLING_ACCOUNT_NAME','')
var varBillingProfileName = readEnvironmentVariable('INFRA_02_BILLING_PROFILE_NAME','')
var varInvoiceSectionName = readEnvironmentVariable('INFRA_OPEX_INVOICE_SECTION_NAME','')

param parSnkBillingScope = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountName}/billingProfiles/${varBillingProfileName}/invoiceSections/${varInvoiceSectionName}'
