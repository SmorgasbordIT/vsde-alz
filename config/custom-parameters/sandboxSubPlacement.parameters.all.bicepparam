/* 
  subSandbox.parameters.all.bicepparam
  Author: J Davis
  Date: 2025-04-03
  Version: 1.0
  
  This file contains the parameters for the subSandbox.bicep file.

*/

using '../../bicep/v0.00.4/modules/sandboxSubPlacement/sandboxSubPlacement.bicep'

// Read environment variables for naming convention
param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

var varAzLocationAbbr = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','')

var varAzUk  = readEnvironmentVariable('AZUREUK','')
var varSnk   = readEnvironmentVariable('SPACENK_ABBR','')
var varSnd   = readEnvironmentVariable('ENV_SANDBOX','')
var varSndx  = readEnvironmentVariable('SND_GRP_NAME','')
var varInfra = readEnvironmentVariable('INFRA_ABBR','')
var varEng   = readEnvironmentVariable('ENG_ABBR','')
var varCTech = readEnvironmentVariable('CTECH_ABBR','')
var varSTech = readEnvironmentVariable('STECH_ABBR','')
var varData  = readEnvironmentVariable('DATA_ABBR','')

param parWorkload = 'Production'

// Read environment variables for Billing Scope Infra_01
var varBillingAccountNameInfra01 = readEnvironmentVariable('INFRA_BILLING_ACCOUNT_NAME','')
var varBillingProfileNameInfra01 = readEnvironmentVariable('INFRA_01_BILLING_PROFILE_NAME','')
var varInvoiceSectionNameInfra01 = readEnvironmentVariable('INFRA_CAPEX_INVOICE_SECTION_NAME','')

// Read environment variables for Billing Scope Eng_01
var varBillingProfileNameEng01 = readEnvironmentVariable('ENG_01_BILLING_PROFILE_NAME','')
var varInvoiceSectionNameEng01 = readEnvironmentVariable('ENG_CAPEX_INVOICE_SECTION_NAME','')

/*
// Read environment variables for Billing Scope Cust_Tech_01
var varBillingProfileNameCTech01 = readEnvironmentVariable('CUST_TECH_01_BILLING_PROFILE_NAME','')
var varInvoiceSectionNameCTech01 = readEnvironmentVariable('CUST_CAPEX_INVOICE_SECTION_NAME','')

// Read environment variables for Billing Scope Supp_Tech_01
var varBillingProfileNameSTech01 = readEnvironmentVariable('SUPP_TECH_01_BILLING_PROFILE_NAME','')
var varInvoiceSectionNameSTech01 = readEnvironmentVariable('SUPP_CAPEX_INVOICE_SECTION_NAME','')

// Read environment variables for Billing Scope Data_01
var varBillingProfileNameData01 = readEnvironmentVariable('DATA_01_BILLING_PROFILE_NAME','')
var varInvoiceSectionNameData01 = readEnvironmentVariable('DATA_CAPEX_INVOICE_SECTION_NAME','')
*/

// Provide the full resource ID of billing scope to use for subscription creation
var varSnkBillingScopeInfra01 = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountNameInfra01}/billingProfiles/${varBillingProfileNameInfra01}/invoiceSections/${varInvoiceSectionNameInfra01}'
var varSnkBillingScopeEng01   = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountNameInfra01}/billingProfiles/${varBillingProfileNameEng01}/invoiceSections/${varInvoiceSectionNameEng01}'
//var varSnkBillingScopeCTech01   = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountNameInfra01}/billingProfiles/${varBillingProfileNameCTech01}/invoiceSections/${varInvoiceSectionNameCTech01}'
//var varSnkBillingScopeSTech01   = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountNameInfra01}/billingProfiles/${varBillingProfileNameSTech01}/invoiceSections/${varInvoiceSectionNameSTech01}'
//var varSnkBillingScopeData01    = '/providers/Microsoft.Billing/billingAccounts/${varBillingAccountNameInfra01}/billingProfiles/${varBillingProfileNameData01}/invoiceSections/${varInvoiceSectionNameData01}'

// Variables & Parameters for Sandbox Group ID
var varSandboxGroupId = '${varAzUk}-${varSnk}-${varSnd}'
param parManagementGroupId = toLower('/providers/Microsoft.Management/managementGroups/${varSandboxGroupId}')

// Infrastructure 
var varSnkSubsSndAliasNameInfra  = toUpper('${varAzLocationAbbr}-${varInfra}-${varSndx}-01')

// Engineering
var varSnkSubsSndAliasNameEng  = toUpper('${varAzLocationAbbr}-${varEng}-${varSndx}-01')

// Custom Tech
//var varSnkSubsSndAliasNameCTech  = toUpper('${varAzLocationAbbr}-${varCTech}-${varSndx}-01')

// Supply Chain Tech
//var varSnkSubsSndAliasNameSTech  = toUpper('${varAzLocationAbbr}-${varSTech}-${varSndx}-01')

// Data Platform
//var varSnkSubsSndAliasNameData  = toUpper('${varAzLocationAbbr}-${varData}-${varSndx}-01')

param parSubscriptions = [
  {
    subscriptionAliasName: varSnkSubsSndAliasNameInfra
    billingScope: varSnkBillingScopeInfra01
  }
  {
    subscriptionAliasName: varSnkSubsSndAliasNameEng
    billingScope: varSnkBillingScopeEng01
  }
]

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Sandbox'
  DeployedBy: 'Cloud Tech'
  CreatedBy: 'jonathan.davis@spacenk.com'
  SvcName: 'Infrastructure'
  SvcOwner: 'Infrastructure@spacenk.com'
}
