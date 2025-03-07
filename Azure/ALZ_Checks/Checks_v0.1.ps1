## Checks

# Run through the following tests to check your permissions.

## Vars

$azName     = "rg-deleteme"
$azMgtName  = "mgt-deleteme"
$azLocation = "UK South"
$azAadSec   = "aad-group-deleteme"

# Login to the right context
az login
az account show

# Use if need to switch Az Subscription
az account set --subscription <az_subscription_id>

# Set defauklt location and grab subscription scope
#export AZURE_DEFAULTS_LOCATION = uksouth
$azSubScope = (az account show --query id)

# Create Entra ID (AAD) Security group
az ad group create --display-name $azAadSec --mail-nickname "JunkMail"
$azAadObjectId = (az ad group show --group $azAadSec --query id)

# Create a Az Management Group
az account management-group create --name $azMgtName
$azMgtScope = ("/providers/Microsoft.Management/managementGroups/" + $azMgtName)

# Create Az Resource Group
az group create --location $azLocation --name $azName

# Create a Az Role assignment for the Management Group
az role assignment create --assignee "26e2deb6-1138-4d13-9f82-7ca1988eb9f4" --role "Reader" --scope $azMgtScope

# Attached an Az Policy (BuiltIn) to the Management Group
az policy assignment create --name $azName --policy "0a914e76-4921-4c19-b460-a2d36003525a" --scope $azMgtScope

## Clean Up

# The following code block will tidy everything up from the checks

az group delete --name $azName --yes
az policy assignment delete --name $azName --scope $azMgtScope
az policy assignment delete --name $azName
az role assignment delete --role Reader --assignee $azAadObjectId --scope $azMgtScope
az role assignment delete --role Reader --assignee $azAadObjectId
az ad group delete --group $azName
az account management-group delete --name $azName


## Configure Azure permissions for ARM tenant deployments
#
# Grant Access to User and/or Service principal at root scope "/" to deploy Enterprise-Scale reference implementation
#
# Note: Please ensure you are logged in as a user with User Access Administrator (UAA) role enabled in Microsoft Entra 
#       tenant and logged in user is not a guest user.

# Sign into AZ CLI, this will redirect you to a webbrowser for authentication, if required
az login
az account show

# If you do not want to use a web browser you can use the following bash
read -sp "Azure password: " AZ_PASS && echo && az login -u <username> -p $azPwd

# Assign Owner role at Tenant root scope ("/") as a UAA to current user (gets object Id of the current user (az login))
az role assignment create --scope "/" --role "Owner" --assignee-object-id $(az ad signed-in-user show --query id) --assignee-principal-type User

#(optional) assign Owner role at Tenant root scope ("/") as a UAA to service principal (set $azSpnDisplayName to your service principal displayname)
$azSpnDisplayName = '<ServicePrincipal DisplayName>'
az role assignment create --scope '/' --role 'Owner' --assignee-object-id $(az ad sp list --display-name $azSpnDisplayName --query "[].id") --assignee-principal-type ServicePrincipal