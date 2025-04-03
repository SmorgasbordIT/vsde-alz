/* 
  subSandbox.parameters.all.bicepparam
  Author: J Davis
  Date: 2025-04-03
  Version: 1.0
  
  This file contains the parameters for the subSandbox.bicep file.

*/

using '../../bicep/v0.00.4/modules/sandboxSubPlacement/sandboxSubPlacement.bicep'

// Read environment variables for naming convention
var varAzLocationAbbr = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','')

var varAzUk  = readEnvironmentVariable('AZUREUK','')
var varSnk   = readEnvironmentVariable('SPACENK_ABBR','')
var varSnd   = readEnvironmentVariable('ENV_SANDBOX','')
var varSndx  = readEnvironmentVariable('SND_GRP_NAME','')
var varInfra = readEnvironmentVariable('INFRA_ABBR','')

param parSnkWorkload = 'DevTest'

// Variables & Parameters for Sandbox Group ID
var varSandboxGroupId = '${varAzUk}-${varSnk}-${varSnd}'

param parSnkSubsSndAliasName  = toUpper('${varAzLocationAbbr}-${varInfra}-${varSndx}-01')

param parSandboxGroupId = toLower('/providers/Microsoft.Management/managementGroups/${varSandboxGroupId}')

// Read environment variables for Billing Scope
var varBillingAccountName = readEnvironmentVariable('INFRA_BILLING_ACCOUNT_NAME','')
var varBillingProfileName = readEnvironmentVariable('INFRA_01_BILLING_PROFILE_NAME','')
var varInvoiceSectionName = readEnvironmentVariable('INFRA_CAPEX_INVOICE_SECTION_NAME','')

param parSnkBillingScope = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountName}/billingProfiles/${varBillingProfileName}/invoiceSections/${varInvoiceSectionName}'
