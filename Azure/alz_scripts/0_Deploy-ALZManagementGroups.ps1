<#
.Synopsis:
  Module: Management Groups deployment using Bicep

.Description:
  The following PowerShell script deploys a management group hierarchy in an Azure tenant.

.Notes
    Author    : J Davis
    Version   : v0.1
    File Name : 0_sbit_deploy_az_management_groups_v0.1.ps1
    Date      : 13/02/2025

    Run cmdlet with elevated Administrator rights.

#>

######################################################## Change Log #######################################################

   # v0.1 - J Davis - Created script and tested deployment of multiple Azure Resource Groups.
   # v0.2 - J Davis - 

###################################################### Original story #####################################################

   # XXXXX - 

###########################################################################################################################

# Remove all Azure credentials, account, and subscription information
Clear-AzContext -Force

# Delete the variable and its value for the current session 
Remove-Variable -Name * -ErrorAction SilentlyContinue

# Set the PSDefaultParameterValues to use the DefaultParameterDictionary
$Global:PSDefaultParameterValues = New-Object "System.Management.Automation.DefaultParameterDictionary"

####################################################### Parameters ########################################################

######################################################## Variables ########################################################

# The Az region
$azMgtLocation           = "UK South"

# Space NK abbreviation
$azSnk                   = "snk"

# Bicep template file paths
$azTemplateFile          = "Azure/SBIT/alz/modules/managementGroups/managementGroups.bicep"
$azTemplateParameterFile = "Azure/SBIT/alz/modules/managementGroups/parameters/managementGroups.params.prod.json"

# Mark the start time of the script execution
$azStartTime  = Get-Date

############################################ Script Body Execution Begins Here ############################################

## Sign into Azure account
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

# Login to Azure - if already logged in, use existing credentials.
Write-Host "Authenticating to Azure..." -ForegroundColor Cyan;
Try {
    $AzureLogin = Get-AzContext
}Catch{
    $null = Login-AzAccount
    $AzureLogin = Get-AzContext
}

If($AzureLogin -and !($SubscriptionID)) {
    [array]$arrNo = (1..5)
    [array]$SubscriptionArray = (Get-AzSubscription)
    [int]$SelectedSub = 0

    # use the current subscription if there is only one subscription available
    If($SubscriptionArray.Count -eq 1) {
        $SelectedSub = 1
    }
    # Get SubscriptionID if one isn't provided
    While($SelectedSub -gt $SubscriptionArray.Count -or $SelectedSub -lt 1) {
        Write-host "Please select a Azure Subscription from the list below" -ForegroundColor Yellow;

        [int]$array = $arrNo.Count
        If([int]$SubscriptionArray.Count -gt [int]$arrNo.Count) {
            $array = $SubscriptionArray.Count;
        }
        $SubscriptionArrayX = For($i = 0; $i -lt $array; $i++) {
            Write-Verbose "$($arrNo[$i]),$($SubscriptionArray[$i])"
            [PSCustomObject]@{
                X = $arrNo[$i]
                SubscriptionName = $SubscriptionArray.Name[$i]
                SubscriptionID   = $SubscriptionArray.Id[$i]
            }
        }
        
        $SubscriptionArrayX | Select-Object X, SubscriptionName , SubscriptionId | Format-Table
        Try{
            $SelectedSub = Read-Host "Please enter a selection from 1 to $($SubscriptionArray.count)" -Verbose -ErrorAction Stop
        }Catch{
            Write-Warning -Message 'Invalid option, please try again....!!'
        }
    }

    Write-Verbose "You Selected Azure Subscription: $($SubscriptionArrayX[$SelectedSub - 1].SubscriptionName)"
    [guid]$SubscriptionID = $($SubscriptionArrayX[$SelectedSub - 1].SubscriptionId)

}
Write-Host "Selecting Azure Subscription: " -NoNewline -ForegroundColor Cyan;
Write-Host "$($SubscriptionArray[$SelectedSub - 1].Name) " -NoNewline -ForegroundColor Yellow;
Write-Host "Subscription Id: $($SubscriptionID.Guid)....." -ForegroundColor Cyan;
$Null = Select-AzSubscription -SubscriptionId $SubscriptionID.Guid

# Deploy into a Tenant Root Group
$azInputObject = @{
    DeploymentName        = ('{0}-alz-MgtDeployment-{1}' -f $azSnk,((Get-Date).ToUniversalTime()).ToString("ddMMyyyy-HHmm"))
    Location              = $azMgtLocation
    TemplateFile          = $azTemplateFile
    TemplateParameterFile = $azTemplateParameterFile
    Verbose               = $true
  }
  New-AzTenantDeployment @azInputObject

  $azTenDeployOutput = Get-AzTenantDeployment -Name $azInputObject.DeploymentName
  If($azTenDeployOutput.ProvisioningState -eq "Succeeded") {
    Write-Host ("Az Tenant Deployment Provisioning State has '[{0}]'!!`n" -f $azTenDeployOutput.ProvisioningState) -ForegroundColor Green;
  }Else{
    Write-Host ("Az Tenant Deployment Provisioning State has '[Failed['!!] `n" -f $azAspName) -ForegroundColor Yellow -BackgroundColor Red;
    Write-Host ("Check the Az Activity Log with the Correlation Id '[{0}]' `n" -f $azTenDeployOutput.CorrelationId) -ForegroundColor Yellow -BackgroundColor Red;
    Return;
  }

# Mark the finish time of the script exectionb
$azFinishTime = Get-Date

# Output the time consumed in seconds
$azTotalTime = ($azFinishTime - $azStartTime).TotalMinutes
Write-Output "The script complete in $azTotalTime minutes."

######################################################## End Script ########################################################