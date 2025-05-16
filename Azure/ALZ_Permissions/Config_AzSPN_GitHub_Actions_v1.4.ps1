function Setup-AzureSpn {
    <#
        .SYNOPSIS
        Automates the setup of a new Azure Service Principal (SPN) and client secret for secure integration with GitHub, enabling protected CI/CD workflows.

        .DESCRIPTION
        This script performs the following:
        - Creates an Azure AD Service Principal for authentication.
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

        PS> . ./Config_AzSPN_GitHub_Actions_v1.2.ps1

        Next, invoke the 'Setup-AzureSpn' function with the specific parameters:

        PS> Setup-AzureSpn -azDisplayName "<DisplayName>" `
                           -azSpnRole "Contributor" `
                           -azSubscriptionId "<SubscriptionID>" `
                           -ghOrgName "<OrgName>" `
                           -ghRepoName "<RepoName>" `
                           -ghEnvNames "Production" `
                           -Verbo

        Replace the placeholders with the specific values to customize the setup.
                
        .NOTES
        Author: J Davis
        Date: 07-05-2025
        Version: 1.4

        .LINK
        https://
    #>

    [CmdletBinding()]  # Enables support for -Verbose, -ErrorAction, etc.

    param (

        # Service Principal Parameters
        [Parameter(Mandatory = $true, HelpMessage = "Display name for the Entra ID Service Principal.")]
        [string]$azDisplayName,

        [Parameter(Mandatory = $true, HelpMessage = "Azure Built-in role. For example: 'Owner', 'Contributor', 'Reader'")]
        [string]$azSpnRole,

        [Parameter(Mandatory = $true, HelpMessage = "The subscription ID where the AKS cluster will be deployed.")]
        [ValidateNotNullOrEmpty()]
        [string]$azSubscriptionId,

        # GitHub Parameters
        [Parameter(Mandatory = $true, HelpMessage = "The GitHub organization name.")]
        [ValidateNotNullOrEmpty()]
        [string]$ghOrgName,

        [Parameter(Mandatory = $true, HelpMessage = "The GitHub repository name.")]
        [ValidateNotNullOrEmpty()]
        [string]$ghRepoName,

        [Parameter(Mandatory = $true, HelpMessage = "List of environment names for GitHub workflows. For example: 'Production', 'Staging', 'Development', 'infra-prd', 'infra-stg', 'infra-dev'")]
        [ValidateNotNullOrEmpty()]
        [string[]]$ghEnvNames
    )

    $azDisplayName = "AZUK-VSDE-ALZ-AAR-GIT-02"
    $azSpnRole = "Contributor"
    $azSubscriptionId = "09b1d16f-45ce-4531-8b2a-50cc9a2f5ab8"
    $ghOrgName = "SmorgasbordIT"
    $ghRepoName = "vsde-alz"
    $ghEnvNames = "SBN-ALZ-Prod"
    
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
            param (
                [string]$SubscriptionId
            )
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

        # Step 1: Create Azure AD Service Principal
        Set-SubscriptionContext -SubscriptionId $azSubscriptionId
        try {
            Write-Verbose "Checking for existing Azure AD Service Principal..."
            $azExistingSpn = Get-AzADServicePrincipal -DisplayName $azDisplayName -ErrorAction SilentlyContinue | Select-Object -First 1

            $azSpnSecret = $null

            if (-not $azExistingSpn) {
                Write-Verbose "Creating new Azure AD Service Principal..."
                $newSpn = New-AzADServicePrincipal -DisplayName $azDisplayName -Role $azSpnRole -Scope "/subscriptions/$azSubscriptionId"

                Start-Sleep -Seconds 5

                $azExistingSpn = Get-AzADServicePrincipal -DisplayName $azDisplayName | Select-Object -First 1

                if ($azExistingSpn) {
                    $azSpnAppId = $azExistingSpn.AppId

                    # Create a new client secret for the SPN
                    Write-Verbose "Creating client secret for the new Service Principal..."
                    $secretObject = New-AzADAppCredential -ApplicationId $azSpnAppId
                    $azSpnSecret = $secretObject.SecretText
                    Write-Verbose "Client secret created successfully."
                }
            } else {
                Write-Verbose "Service Principal already exists."
                $azSpnAppId = $azExistingSpn.AppId

                # Optionally create or rotate the secret
                Write-Verbose "Generating new client secret for existing Service Principal..."
                $secretObject = New-AzADAppCredential -ApplicationId $azSpnAppId
                $azSpnSecret = $secretObject.SecretText
                Write-Verbose "Client secret created successfully."
            }

            if (-not $azSpnAppId -or -not $azSpnSecret) {
                throw "Unable to retrieve the Azure AD Service Principal or its secret."
            }

            Write-Verbose "Using AppId: $azSpnAppId"
        } catch {
            Write-Error "Failed to create or verify the Service Principal: $_"
            return
        }

        # Step 2: Create the GitHub Actions Secrets
        try {
            Write-Verbose "Creating or verifying GitHub Actions Secrets..."
        
            # Function to modularise secret creation
            function Set-GitHubSecret {
                param (
                    [string]$Name,
                    [string]$Value,
                    [string]$Env
                )
                Write-Verbose "Creating or updating secret '$Name' for environment '$Env'"
                gh secret set $Name --repo "$($ghOrgName)/$($ghRepoName)" --env $Env --body $Value
            }
        
            # Define the secrets and their values
            $azSecrets = @{
                "ENTRA_CLIENT_ID"       = $azSpnAppId
                "ENTRA_CLIENT_SECRET"   = $azSpnSecret
                "ENTRA_SUBSCRIPTION_ID" = $azSubscriptionId
                "ENTRA_TENANT_ID"       = (Get-AzContext).Tenant.Id
            }
        
            foreach ($env in $ghEnvNames) {
                foreach ($azSecretName in $azSecrets.Keys) {
                    $azSecretValue = $azSecrets[$azSecretName]
                    Set-GitHubSecret -Name $azSecretName -Value $azSecretValue -Env $env
                }
            }
        
            Write-Verbose "All secrets have been created or updated successfully."
        } catch {
            Write-Error "Failed to create or update environment secrets or variables in GitHub: $_"
            return
        }
    }

    end {
        Write-Verbose "Script execution completed successfully!"
    }
}
