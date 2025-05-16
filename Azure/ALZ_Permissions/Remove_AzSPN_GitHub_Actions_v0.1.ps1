function Cleanup-AzureSpn {
    <#
        .SYNOPSIS
        Cleans up an Azure AD Service Principal and deletes associated client secrets, as well as removes GitHub Actions secrets.
        
        .DESCRIPTION
        This function reverses the actions taken by the Setup-AzureSpn function, performing the following:
        - Deletes the Azure AD Service Principal.
        - Removes the client secret associated with the Azure AD Service Principal.
        - Removes the RBAC role for the SPN for the Azure Landing Zone (ALZ)
        - Deletes the GitHub repository secrets created for the Service Principal.

        .PARAMETER azDisplayName
        The display name for the Azure AD Service Principal to be deleted.

        .PARAMETER azSubscriptionId
        The Azure subscription ID associated with the Service Principal.

        .PARAMETER ghOrgName
        The GitHub organization name.

        .PARAMETER ghRepoNames
        A list of GitHub repository names from which secrets should be deleted.

        .PARAMETER ghEnvNames
        A list of environment names in the GitHub repositories from which secrets should be deleted.
        - "Development"
        - "Staging"
        - "Production"

        .INPUTS
        None. This function does not accept piped input.

        .OUTPUTS
        None. This function outputs verbose information to the console during execution.

        .EXAMPLE
        Load the PowerShell script into the session:

        PS> . ./Remove_AzSPN_GitHub_Actions_v0.1.ps1

        Next, invoke the 'Setup-AzureSpn' function with the specific parameters.

        PS> Cleanup-AzureSpn -azDisplayName "<DisplayName>" `
                             -azSubscriptionId "<SubscriptionID>" `
                             -ghOrgName "<OrgName>" `
                             -ghRepoName ("<RepoName>", "<RepoName>") `
                             -ghEnvNames "<GitHubEnvironment>" `
                             -Verbose

        .NOTES
        Author: J Davis
        Date: 12-05-2025
        Version: 0.1
    #>

    [CmdletBinding()] 
    param (

        # Service Principal Parameters
        [Parameter(Mandatory = $true, HelpMessage = "Display name of the Azure AD Service Principal to be deleted.")]
        [string]$azDisplayName,

        [Parameter(Mandatory = $true, HelpMessage = "The subscription ID associated with the Service Principal.")]
        [ValidateNotNullOrEmpty()]
        [string]$azSubscriptionId,

        # GitHub Parameters
        [Parameter(Mandatory = $true, HelpMessage = "The GitHub organization name.")]
        [ValidateNotNullOrEmpty()]
        [string]$ghOrgName,

        [Parameter(Mandatory = $true, HelpMessage = "List of GitHub repository names.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$ghRepoNames,

        [Parameter(Mandatory = $true, HelpMessage = "List of environment names for GitHub workflows.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$ghEnvNames
    )

    begin {
        # Global settings
        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'

        # Validate GitHub CLI is installed
        try {
            Get-Command gh -ErrorAction Stop | Out-Null
            gh auth status --hostname github.com --check > $null 2>&1
            Write-Verbose "GitHub CLI is available and authenticated."
        } catch {
            Write-Error "GitHub CLI ('gh') is either not installed or not authenticated. Please install and run 'gh auth login'."
            exit 1
        }

        # Function to set the subscription context
        function Set-SubscriptionContext {
            param ([string]$SubscriptionId)
            Write-Verbose "Selecting subscription context for '$SubscriptionId'..."
            try {
                Select-AzSubscription -SubscriptionId $SubscriptionId
                Write-Verbose "Successfully set subscription context to '$SubscriptionId'."
            } catch {
                Write-Error "Failed to set subscription context: $_"
                return
            }
        }
    }

    process {
        # Step 1: Delete Azure AD Service Principal and its client secrets
        Set-SubscriptionContext -SubscriptionId $azSubscriptionId

        try {
            Write-Verbose "Checking for Azure AD Service Principal '$azDisplayName'..."
            $azExistingSpn = Get-AzADServicePrincipal -DisplayName $azDisplayName -ErrorAction SilentlyContinue | Select-Object -First 1

            if ($azExistingSpn) {
                $azSpnAppId = $azExistingSpn.AppId

                Write-Verbose "Removing role assignments for SPN '$azDisplayName'..."
                $roleAssignments = Get-AzRoleAssignment -ObjectId $azExistingSpn.Id -ErrorAction SilentlyContinue
                foreach ($assignment in $roleAssignments) {
                    Write-Verbose "Removing role assignment: Role='$($assignment.RoleDefinitionName)', Scope='$($assignment.Scope)'"
                    Remove-AzRoleAssignment -ObjectId $azExistingSpn.Id -Scope $assignment.Scope -RoleDefinitionName $assignment.RoleDefinitionName -ErrorAction Stop
                }

                Write-Verbose "Removing client secrets for the Service Principal..."
                $allSecrets = Get-AzADAppCredential -ApplicationId $azSpnAppId
                foreach ($secret in $allSecrets) {
                    Write-Verbose "Removing client secret with KeyId $($secret.KeyId)..."
                    Remove-AzADAppCredential -ApplicationId $azSpnAppId -KeyId $secret.KeyId
                }

                Write-Verbose "Deleting Azure AD Service Principal '$azDisplayName'..."
                Remove-AzADServicePrincipal -ObjectId $azExistingSpn.Id
                Write-Verbose "Service Principal and associated secrets deleted successfully."

                Write-Verbose "Checking for Azure AD Application to delete..."
                $azApp = Get-AzADApplication -DisplayName $azDisplayName -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($azApp) {
                    Write-Verbose "Deleting Azure AD Application with AppId $($azApp.AppId)..."
                    Remove-AzADApplication -ObjectId $azApp.Id
                    Write-Verbose "Azure AD Application deleted."
                } else {
                    Write-Verbose "No Azure AD Application found with display name '$azDisplayName'."
                }
            } else {
                Write-Verbose "No Service Principal found with the display name '$azDisplayName'."
            }
        } catch {
            Write-Error "Failed to delete the Azure AD Service Principal or its secrets: $_"
            return
        }

        # Step 2: Delete GitHub Actions Secrets
        try {
            Write-Verbose "Removing GitHub Actions Secrets..."
        
            foreach ($repo in $ghRepoNames) {
                foreach ($env in $ghEnvNames) {
                    $secretsToDelete = @(
                        "AZURE_CLIENT_ID",
                        "AZURE_CLIENT_SECRET",
                        "AZURE_SUBSCRIPTION_ID",
                        "AZURE_TENANT_ID"
                    )
                    foreach ($secretName in $secretsToDelete) {
                        try {
                            Write-Verbose "Removing GitHub secret '$secretName' for repo '$repo' and environment '$env'..."
                            gh secret delete $secretName --repo "$($ghOrgName)/$repo" --env $env
                            Write-Verbose "Deleted secret '$secretName' from '$env' in repo '$repo'."
                        } catch {
                            Write-Warning "Secret '$secretName' not found or already deleted in '$env' of repo '$repo'. Error: $_"
                        }
                    }
                }
            }

            Write-Verbose "GitHub secrets have been removed successfully."
        } catch {
            Write-Error "Failed to remove GitHub Actions secrets: $_"
            return
        }
    }

    end {
        Write-Verbose "Cleanup completed successfully!"
    }
}