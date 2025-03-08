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
$gitOrgName   = "SmorgasbordIT"
$gitRepoName  = "vsde-alz"
$azAppRegName = New-AzADApplication -DisplayName "AZUK-VSDE-ALZ-AAR-GIT-01"



$azAppRegNameProd = ($($azAppRegName.DisplayName) + "-SBN-ALZ-Prod")

$azAdAppFcProd = New-AzADAppFederatedCredential -Name $azAppRegNameProd `
                                                -ApplicationObjectId $azAppRegName.Id `
                                                -Issuer "https://token.actions.githubusercontent.com" `
                                                -Audience "api://AzureADTokenExchange" `
                                                -Subject "repo:$($gitOrgName)/$($gitRepoName):environment:SBN-ALZ-Prod"
                                                

                                                $azAdAppFcProd

<## Output
Audience             : {api://AzureADTokenExchange}
Description          : 
Id                   : 39001829-f165-4134-bef5-344d3616fff4
Issuer               : https://token.actions.githubusercontent.com
Name                 : AZUK-VSDE-ALZ-AAR-GIT-01
ResourceGroupName    : 
Subject              : repo:SmorgasbordIT/vsde-alz:environment:SBN-ALZ-Prod
AdditionalProperties : {[@odata.context, https://graph.microsoft.com/v1.0/$metadata#applications('0f895dc0-535d-4854-b76c-b42d1d51
                        8009')/federatedIdentityCredentials/$entity], [id, 39001829-f165-4134-bef5-344d3616fff4]}
##>

$azAppRegNamebranch = ($($azAppRegName.DisplayName) + "-branch")

$azAdAppFcMain = New-AzADAppFederatedCredential -Name $azAppRegNamebranch `
                                                -ApplicationObjectId $azAppRegName.Id `
                                                -Issuer "https://token.actions.githubusercontent.com" `
                                                -Audience "api://AzureADTokenExchange" `
                                                -Subject "repo:$($gitOrgName)/$($gitRepoName):ref:refs/heads/main"
                                                
                                                $azAdAppFcMain

<## Output
Audience             : {api://AzureADTokenExchange}
Description          : 
Id                   : d0fdb017-0c5e-4be9-96f6-4899f962d6ac
Issuer               : https://token.actions.githubusercontent.com
Name                 : AZUK-VSDE-ALZ-AAR-GIT-01-Main
ResourceGroupName    : 
Subject              : repo:SmorgasbordIT/vsde-alz:ref:refs/heads/main
AdditionalProperties : {[@odata.context, https://graph.microsoft.com/v1.0/$metadata#applications('0f895dc0-535d-4854-b76c-b42d1d51
                       8009')/federatedIdentityCredentials/$entity], [id, d0fdb017-0c5e-4be9-96f6-4899f962d6ac]}
##>

## Resource Group
$productionResourceGroup = Get-AzResourceGroup -Name "AZUKS-RG-MGT-LOG"

$azSpn = New-AzADServicePrincipal -ApplicationId $($azAppRegName.AppId)

New-AzRoleAssignment -ApplicationId $($azAppRegName.AppId) `
                     -RoleDefinitionName "Owner" `
                     -Scope $($productionResourceGroup.ResourceId)

## Tenant
$azSpn = New-AzADServicePrincipal -ApplicationId $($azAppRegName.AppId)

New-AzRoleAssignment -ApplicationId $azSpn.AppId `
                     -RoleDefinitionName "Contributor" `
                     -Scope '/'

## Remove Role Assignment
Get-AzRoleAssignment -Scope "/"

# Find the object Id of the one you want to remove
$azX = Get-AzRoleAssignment -Scope "/" -ObjectId "cf2d0d95-9cb6-46d3-8648-582aebf2c120"

Remove-AzRoleAssignment -Scope "/" -ObjectId $azX.ObjectId -RoleDefinitionName "Owner"