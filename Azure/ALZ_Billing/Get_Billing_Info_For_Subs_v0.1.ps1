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

# Find the billing accounts
$azBillDetails = Get-AzBillingAccount

$azBillDetails.Name

# Find the billing profile and invoice sections
$azBillProfiles = Get-AzBillingProfile -BillingAccountName $azBillDetails.Name[0]

$azBillProfiles.Name

$azInvSection = Get-AzInvoiceSection -BillingAccountName $azBillDetails.Name[0] `
                                     -BillingProfileName $azBillProfiles.Name[2]

$azInvSection.Name

# String used for the billing scope
"/providers/Microsoft.Billing/billingAccounts/$($azBillDetails.Name[0])/billingProfiles/$($azBillProfiles.Name[2])/invoiceSections/$($azInvSection.Name)"
