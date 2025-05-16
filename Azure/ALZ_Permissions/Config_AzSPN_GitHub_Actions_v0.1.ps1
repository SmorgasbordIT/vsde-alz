Function Setup-AzureSpn {
    <#
        .SYNOPSIS
        Automates the setup of a new Azure Service Principal (SPN) and client secret for secure integration with GitHub, enabling protected CI/CD workflows.

        .DESCRIPTION
        This script performs the following:
        - Creates an Azure AD Service Principal for authentication.
        - Configures GitHub federated identity with Azure AD for seamless CI/CD.
        - Configures GitHub repository secrets for secure authentication.

        .PARAMETER azDisplayName
        The display name for the Azure AD Service Principal.

        .PARAMETER azSpnRole
        The Azure Built-in role

        .PARAMETER azSubscriptionId
        The Azure subscription ID where the GitHub Actions workflow will deploy resources.

        .PARAMETER ghOrgName
        The GitHub organization name.

        .PARAMETER ghRepoName
        The GitHub repository name for storing deployment manifests.

        .PARAMETER ghEnvNames
        The list of environment names for GitHub workflows.

        .INPUTS
        None. This script does not accept piped input.

        .OUTPUTS
        None. This script outputs verbose information to the console during execution.

        .EXAMPLE
        Load the PowerShell script into the session:

        PS> . ./Config_AzSPN_GitHub_Actions_vX.X.ps1

        PS> Setup-AzureSpn -azDisplayName "<DisplayName>" `
                           -azSpnRole "Contributor" `
                           -azSubscriptionId "<SubscriptionID>" `
                           -ghOrgName "<OrgName>" `
                           -ghRepoName "<RepoName>" `
                           -ghEnvNames "Production"
                
        .NOTES
        Author: J Davis
        Date: 07-05-2025
        Version: 0.1

        .LINK
        https://
    #>

    Param (
        # Service Principal Parameters
        [Parameter(Mandatory = $true, HelpMessage = "Display name for the Entra ID Service Principal.")]
        [String]$azDisplayName,

        [Parameter(Mandatory = $true, HelpMessage = "Azure Built-in role. For example: 'Owner', 'Contributor', 'Reader'")]
        [String]$azSpnRole,

        [Parameter(Mandatory = $true, HelpMessage = "The subscription ID where the AKS cluster will be deployed.")]
        [ValidateNotNullOrEmpty()]
        [String]$azSubscriptionId,

        # GitHub Parameters
        [Parameter(Mandatory = $true, HelpMessage = "The GitHub organization name.")]
        [ValidateNotNullOrEmpty()]
        [String]$ghOrgName,

        [Parameter(Mandatory = $true, HelpMessage = "The GitHub repository name.")]
        [ValidateNotNullOrEmpty()]
        [String]$ghRepoName,

        [Parameter(Mandatory = $true, HelpMessage = "List of environment names for GitHub workflows. For example: 'Production', 'Staging', 'Development', 'infra-prd', 'infra-stg', 'infra-dev'")]
        [ValidateNotNullOrEmpty()]
        [String[]]$ghEnvNames
    )

    $azDisplayName = "AZUK-VSDE-ALZ-AAR-GIT-03"
    $azSpnRole = "Contributor"
    $azSubscriptionId = "09b1d16f-45ce-4531-8b2a-50cc9a2f5ab8"
    $ghOrgName = "SmorgasbordIT"
    $ghRepoName = "vsde-alz"
    $ghEnvNames = "SBN-ALZ-Prod"

    
    Begin {

        # Global settings
        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'

        # Helper function to set the subscription context
        Function Set-SubscriptionContext {
            Param (
                [string]$SubscriptionId
            )
            Write-Verbose "Selecting subscription context for '$SubscriptionId'..."
            Try {
                Select-AzSubscription -SubscriptionId $SubscriptionId
                Write-Verbose "Successfully set subscription context to '$SubscriptionId'."
            } Catch {
                Write-Error "Failed to set subscription context: $_"
                Exit 1
            }
        }
    }

    Process {
        
        # Step 1: Create Azure AD Service Principal
        Set-SubscriptionContext -SubscriptionId $azSubscriptionId
        Try {
            Write-Verbose "Checking for existing Azure AD Service Principal..."
            $azExistingSpn = Get-AzADServicePrincipal -DisplayName $azDisplayName -ErrorAction SilentlyContinue

            If (-not $azExistingSpn) {
                $azSpn = New-AzADServicePrincipal -DisplayName $azDisplayName -Role $azSpnRole -Scope "/subscriptions/$azSubscriptionId"
                Write-Verbose "Service Principal created successfully. AppId: $($azSpn.AppId)"
            } Else {
                $azSpn = $azExistingSpn
                Write-Verbose "Service Principal already exists. AppId: $($azSpn.AppId)"
            }
        } Catch {
            Write-Error "Failed to create or verify the Service Principal: $_"
            Exit 1
        }

        # Step 2: Create the GitHub Actions Secrets
        Try {
            Write-Verbose "Creating or verifying GitHub Actions Secrets..."

            # Define the secrets and their values
            $azSecrets = @{
                "ENTRA_CLIENT_ID"           = $azSpn.AppId
                "ENTRA_SUBSCRIPTION_ID"     = $azSubscriptionId
                "ENTRA_TENANT_ID"           = (Get-AzContext).Tenant.Id
            }

            Foreach ($azSecretName in $azSecrets.Keys) {
                If (-not $ghEnvNames) {

                    # Create or update repository secret
                    $azSecretValue = $azSecrets[$azSecretName]
                    Write-Verbose "Creating or updating repository secret in : $azSecretName"
                    gh secret set $azSecretName --repo "$($ghOrgName)/$($ghRepoName)" --body $azSecretValue
                } Else {

                    # Create or update environment secret
                    $azSecretValue = $azSecrets[$azSecretName]
                    Write-Verbose "Creating or updating environment secret in : $azSecretName"
                    gh secret set $azSecretName --repo "$($ghOrgName)/$($ghRepoName)" --env $ghEnvNames --body $azSecretValue
                }
            }
            Write-Verbose "All secrets have been created or updated successfully."

        } Catch {
            Write-Error "Failed to create or update environment secrets or variables in GitHub: $_"
            Exit 1
        }
    }

    End {
        Write-Verbose "Script execution completed successfully!"
    }
}
