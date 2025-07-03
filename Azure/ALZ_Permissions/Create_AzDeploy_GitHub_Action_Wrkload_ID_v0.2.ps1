# Sign into Azure from Powershell, this will redirect you to a webbrowser for authentication, if required
$azLogIn = Read-Host "Do you want to login to Azure with your account (only one time per PowerShell session)? [Yes/No]";
    If("Yes" -eq $azLogin) {
        Write-Host "Logging into Azure....."  -ForegroundColor Yellow;
        Login-AzAccount;
    }Elseif("Y" -eq $azLogIn) {
        Write-Host "Logging into Azure....."  -ForegroundColor Yellow;
        Login-AzAccount;
    }Elseif("No" -eq $azLogin) {
        Write-Host "Skipping user Login as [No] was selected....."  -ForegroundColor Yellow -BackgroundColor Red;
    }Elseif("N" -eq $azLogin) {
        Write-Host "Skipping user Login as [N] was selected....."  -ForegroundColor Yellow -BackgroundColor Red;
    }

## Authenticating Azure Deployments in GitHub Actions with Microsoft Entra ID Workload Identities
# HTTPS: https://github.com/Space-NK-Cloud-Infrastructure/azure-landing-zones.git
# SSH  : git@github.com:Space-NK-Cloud-Infrastructure/azure-landing-zones.git
$gitOrgName   = "Space-NK-Cloud-Infrastructure"
$gitRepoName  = "pre-azure-landing-zones"
#$gitRepoName  = "pre-azure-landing-zones"
#$azAppRegName = New-AzADApplication -DisplayName "AZUKS-SNK-ALZ-AAR-GH-PRD-01"
#$azAppRegName = New-AzADApplication -DisplayName "AZUKW-SNK-ALZ-AAR-GH-PRD-01"
#$azAppRegName = New-AzADApplication -DisplayName "AZUKS-SNK-ALZ-AAR-GH-PRE-01"
$azAppRegName = New-AzADApplication -DisplayName "AZUKW-SNK-ALZ-AAR-GH-PRE-01"

#$azGhEnv = "prd-uks"
#$azGhEnv = "prd-ukw"
#$azGhEnv = "pre-uks"
$azGhEnv = "pre-ukw"

$azAppRegNameProd = ($($azAppRegName.DisplayName) + "-" + $azGhEnv)

$azAdAppFcProd = New-AzADAppFederatedCredential -Name $azAppRegNameProd `
                                                -ApplicationObjectId $azAppRegName.Id `
                                                -Issuer "https://token.actions.githubusercontent.com" `
                                                -Audience "api://AzureADTokenExchange" `
                                                -Subject "repo:$($gitOrgName)/$($gitRepoName):environment:$($azGhEnv)"
                                                

                                                $azAdAppFcProd

<## Output
Audience             : {api://AzureADTokenExchange}
Description          : 
Id                   : 7d74b262-c7e9-42df-8144-862a55b62a63
Issuer               : https://token.actions.githubusercontent.com
Name                 : AZUK-SNK-ALZ-AAR-GIT-01-Production
ResourceGroupName    : 
Subject              : repo:Space-NK-Cloud-Infrastructure/azure-landing-zones:environment:Production
AdditionalProperties : {[@odata.context, https://graph.microsoft.com/v1.0/$metadata#applications('53cc9038-ee21-4a55-81c8-912a246b7764')/federatedIdentityCredentials/$entity], [id, 7d74b262-c7e9-42df-8144-862a55b62a63]}
##>

$azAppRegNamebranch  = ($($azAppRegName.DisplayName) + "-branch-" + $azGhEnv)

$azAdAppFcProduction = New-AzADAppFederatedCredential -Name $azAppRegNamebranch `
                                                      -ApplicationObjectId $azAppRegName.Id `
                                                      -Issuer "https://token.actions.githubusercontent.com" `
                                                      -Audience "api://AzureADTokenExchange" `
                                                      -Subject "repo:$($gitOrgName)/$($gitRepoName):ref:refs/heads/$($azGhEnv)"
                                                
                                                      $azAdAppFcProduction

<## Output
Audience             : {api://AzureADTokenExchange}
Description          : 
Id                   : 87d689ed-488e-48c3-92c8-a526985bdbce
Issuer               : https://token.actions.githubusercontent.com
Name                 : AZUK-SNK-ALZ-AAR-GIT-01-branch
ResourceGroupName    : 
Subject              : repo:Space-NK-Cloud-Infrastructure/azure-landing-zones:ref:refs/heads/production
AdditionalProperties : {[@odata.context, https://graph.microsoft.com/v1.0/$metadata#applications('53cc9038-ee21-4a55-81c8-912a246b7764')/federatedIdentityCredentials/$entity], [id, 87d689ed-488e-48c3-92c8-a526985bdbce]}
##>

## Add the App Reg (Service principal) to the 

## Resource Group
$productionResourceGroup = Get-AzResourceGroup -Name "AZUK-RG-MGT-LOG"

$azSpn = New-AzADServicePrincipal -ApplicationId $($azAppRegName.AppId)

New-AzRoleAssignment -ApplicationId $($azAppRegName.AppId) `
                     -RoleDefinitionName "Contributor" `
                     -Scope $($productionResourceGroup.ResourceId)

## Tenant
$azSpn = New-AzADServicePrincipal -ApplicationId $($azAppRegName.AppId)

New-AzRoleAssignment -ApplicationId $azSpn.AppId `
                     -RoleDefinitionName "Contributor" `
                     -Scope '/'

## Remove Role Assignment
Get-AzRoleAssignment -Scope "/"

# Find the object Id of the one you want to remove
<#
RoleAssignmentName : 558c79bc-bc6f-411b-94d0-22d11337ee25
RoleAssignmentId   : /providers/Microsoft.Authorization/roleAssignments/558c79bc-bc6f-411b-94d0-22d11337ee25
Scope              : /
DisplayName        : AZUK-SNK-ALZ-AAR-GH-PRD-UKS-01
SignInName         : 
RoleDefinitionName : Contributor
RoleDefinitionId   : b24988ac-6180-42a0-ab88-20f7382dd24c
ObjectId           : 94ea1d6e-e02e-4983-bdd0-6ef190a81777
ObjectType         : ServicePrincipal
CanDelegate        : False
Description        : 
ConditionVersion   : 
Condition          : 
#>

# Remove the Role Assignment
Get-AzRoleAssignment > roleass.txt # Use to find the role assignment object id using the displayname. "DisplayName        : AZUK-SNK-ALZ-AAR-GH-PRD-UKS-01"

$azX = Get-AzRoleAssignment -Scope "/" -ObjectId "3ddd4e71-d5af-4c45-b71e-d9e5e6020483"

Remove-AzRoleAssignment -Scope "/" -ObjectId $azX.ObjectId -RoleDefinitionName "Contributor"