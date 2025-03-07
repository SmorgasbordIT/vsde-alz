## Configure Azure permissions for ARM tenant deployments
#
# Grant Access to User and/or Service principal at root scope "/" to deploy Enterprise-Scale reference implementation
#
# Note: Please ensure you are logged in as a user with User Access Administrator (UAA) role enabled in Microsoft Entra 
#       tenant and logged in user is not a guest user.

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

# Get object Id of the current user (that is used above)
$azUser = Get-AzADUser -UserPrincipalName (Get-AzContext).Account

# Assign Owner role at Tenant root scope ("/") as a User Access Administrator to current user
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $azUser.Id

# (optional) Assign Owner role at Tenant root scope ("/") as a User Access Administrator to service principal
# (set $azSpnDisplayName to your service principal displayname)
$azSpnDisplayName = "joda10-AZUKS_VSDE_ALZ-43889d90-311e-4e05-8197-96a36f8723af"
$azSpn = (Get-AzADServicePrincipal -DisplayName $azSpnDisplayName).id
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $azSpn