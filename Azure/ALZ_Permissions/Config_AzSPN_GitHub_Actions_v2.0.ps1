function Setup-AzureSpn {
    <#
        .SYNOPSIS
        Automates the setup of a new Azure Service Principal (SPN) and client secret for secure integration with GitHub, enabling protected CI/CD workflows.

        .DESCRIPTION
        This script performs the following:
        - Creates an Azure AD Service Principal for authentication.
        - Create a RBAC role for the SPN for the Azure Landing Zone (ALZ)
        - Configures GitHub repository secrets for secure authentication.

        .PARAMETER azDisplayName
        The display name for the Azure AD Service Principal.

        .PARAMETER azSpnRole
        The Azure Built-in role

        .PARAMETER azSpnSecretExpiryInDays
        Specifies the number of days until the client secret expires. If not explicitly provided, the expiry duration is automatically determined based on the environment inferred from the azDisplayName:
        - "DEV" = 365 days
        - "STG" = 180 days
        - "PRD" = 90 days

        .PARAMETER azSubscriptionId
        The Azure subscription ID where the GitHub Actions workflow will deploy resources.

        .PARAMETER ghOrgName
        The GitHub organization name.

        .PARAMETER ghRepoName
        The GitHub repository name for storing deployment manifests.

        .PARAMETER ghEnvNames
        The list of environment names for GitHub workflows.
        - "Development"
        - "Staging"
        - "Production"

        .INPUTS
        None. This script does not accept piped input.

        .OUTPUTS
        None. This script outputs verbose information to the console during execution.

        .EXAMPLE
        Load the PowerShell script into the session:

        PS> . ./Config_AzSPN_GitHub_Actions_v2.0.ps1

        Next, invoke the 'Setup-AzureSpn' function with the specific parameters. If `azSpnSecretExpiryInDays` is not provided,
        the script will automatically set the expiry based on the `azDisplayName` (DEV = 365 days, STG = 180 days, PRD = 90 days):

        PS> Setup-AzureSpn -azDisplayName "<DisplayName>" `
                        -azSpnRole "Contributor" `
                        -azSubscriptionId "<SubscriptionID>" `
                        -ghOrgName "<OrgName>" `
                        -ghRepoName ("<RepoName>", "<RepoName>") `
                        -ghEnvNames "<GitHubEnvironment>" `
                        -Verbose

        Replace the placeholders with the specific values to customize the setup. If `azSpnSecretExpiryInDays` is omitted,
        the expiry will be automatically set based on the environment name in `azDisplayName`.

        .NOTES
        Author: J Davis
        Date: 07-05-2025
        Version: 2.0

    #>

    [CmdletBinding()] # Enables support for -Verbose, -ErrorAction, etc.
    param (

        # Service Principal Parameters
        [Parameter(Mandatory = $true, HelpMessage = "Display name for the Entra ID Service Principal.")]
        [string]$azDisplayName,

        [Parameter(Mandatory = $true, HelpMessage = "Azure Built-in role. For example: 'Owner', 'Contributor', 'Reader'")]
        [string]$azSpnRole,

        [Parameter(Mandatory = $false, HelpMessage = "Number of days until the client secret expires.")]
        [int]$azSpnSecretExpiryInDays,

        [Parameter(Mandatory = $true, HelpMessage = "The subscription ID where the AKS cluster will be deployed.")]
        [ValidateNotNullOrEmpty()]
        [string]$azSubscriptionId,

        # GitHub Parameters
        [Parameter(Mandatory = $true, HelpMessage = "The GitHub organization name.")]
        [ValidateNotNullOrEmpty()]
        [string]$ghOrgName,

        [Parameter(Mandatory = $true, HelpMessage = "The GitHub repository name.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$ghRepoNames,

        [Parameter(Mandatory = $true, HelpMessage = "List of environment names for GitHub workflows. For example: 'Production', 'Staging', 'Development', 'infra-prd', 'infra-stg', 'infra-dev'")]
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

        # Step 1: Create Azure AD Service Principal
        Set-SubscriptionContext -SubscriptionId $azSubscriptionId

        # Automatically set secret expiry based on azDisplayName if not provided
        if (-not $azSpnSecretExpiryInDays) {
            $azSpnDisplayNameUpper = $azDisplayName.ToUpper()

            switch -Regex ($azSpnDisplayNameUpper) {
                'DEV'        { $azSpnSecretExpiryInDays = 365; break }
                'STG|QA|UAT' { $azSpnSecretExpiryInDays = 180; break }
                'PRD'   { $azSpnSecretExpiryInDays = 90; break }
                default      { $azSpnSecretExpiryInDays = 365 }
            }

            Write-Verbose "Secret expiry automatically set to $azSpnSecretExpiryInDays days based on azDisplayName '$azDisplayName'"
        }

        try {
            Write-Verbose "Checking for existing Azure AD Service Principal..."
            $azExistingSpn = Get-AzADServicePrincipal -DisplayName $azDisplayName -ErrorAction SilentlyContinue | Select-Object -First 1
            $azSpnSecret = $null

            if (-not $azExistingSpn) {
                Write-Verbose "Creating new Azure AD Service Principal..."
                $azNewSpn = New-AzADServicePrincipal -DisplayName $azDisplayName -Role $azSpnRole -Scope "/subscriptions/$azSubscriptionId"

                Start-Sleep -Seconds 5

                $azExistingSpn = Get-AzADServicePrincipal -DisplayName $azDisplayName | Select-Object -First 1
                if ($azExistingSpn) {
                    $azSpnAppId = $azExistingSpn.AppId

                    # Create a new client secret for the SPN
                    Write-Verbose "Creating client secret for the new Service Principal..."
                    $azStartDate = Get-Date
                    $azEndDate = $azStartDate.AddDays($azSpnSecretExpiryInDays)
                    $azSecretObject = New-AzADAppCredential -ApplicationId $azSpnAppId -StartDate $azStartDate -EndDate $azEndDate
                    $azSpnSecret = $azSecretObject.SecretText
                    Write-Verbose "Client secret created successfully."

                    # Remove other old secrets
                    Write-Verbose "Cleaning up old client secrets..."
                    $azAllSecrets = Get-AzADAppCredential -ApplicationId $azSpnAppId
                    foreach ($azSecret in $azAllSecrets) {
                        if ($azSecret.KeyId -ne $azSecretObject.KeyId) {
                            Write-Verbose "Removing old client secret with KeyId $($azSecret.KeyId)..."
                            Remove-AzADAppCredential -ApplicationId $azSpnAppId -KeyId $azSecret.KeyId
                        }
                    }
                    Write-Verbose "Old secrets cleanup completed."

                    # Add the current user as an Owner to the SPN using Microsoft Graph API
                    try {
                        Write-Verbose "Adding current user as Owner to the SPN application..."

                        $azCurrentUserObjectId = (Get-AzADUser -UserPrincipalName (Get-AzContext).Account).Id
                        $azSpnAppObjectId = (Get-AzADApplication -ApplicationId $azSpnAppId).Id

                        Write-Verbose "Checking if current user is already an owner..."
                        $existingOwnersResponse = Invoke-AzRestMethod -Method GET -Uri "https://graph.microsoft.com/v1.0/applications/$azSpnAppObjectId/owners"
                        $existingOwners = ($existingOwnersResponse.Content | ConvertFrom-Json).value

                        if ($existingOwners -and $existingOwners.Count -gt 0) {
                            $alreadyOwner = $existingOwners.id -contains $azCurrentUserObjectId
                        } else {
                            $alreadyOwner = $false
                        }

                        if ($alreadyOwner) {
                            Write-Verbose "Current user is already an owner. Skipping add."
                        } else {
                            Write-Verbose "Current user is not an owner. Proceeding to add..."

                            # Get the access token for Microsoft Graph
                            $graphToken = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com/"
                            $accessToken = $graphToken.Token

                            # Construct the URI
                            $uri = "https://graph.microsoft.com/v1.0/applications/$azSpnAppObjectId/owners/`$ref"

                            # Prepare headers
                            $headers = @{
                                "Content-Type" = "application/json"
                                "Authorization" = "Bearer $accessToken"  # Ensure to use an access token for authentication
                            }

                            $body = @{
                                "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$azCurrentUserObjectId"
                            } | ConvertTo-Json -Depth 3

                            # Use Invoke-RestMethod for making API calls
                            Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
                            Write-Verbose "Successfully added current user as an Owner to the SPN."
                        }
                    } catch {
                        Write-Warning "Failed to add current user as Owner to the SPN: $_"
                    }
                }
            } else {
                Write-Verbose "Service Principal already exists."
                $azSpnAppId = $azExistingSpn.AppId

                # Optionally create or rotate the secret
                Write-Verbose "Generating new client secret for existing Service Principal..."
                $azStartDate = Get-Date
                $azEndDate = $azStartDate.AddDays($azSpnSecretExpiryInDays)
                $azSecretObject = New-AzADAppCredential -ApplicationId $azSpnAppId -StartDate $azStartDate -EndDate $azEndDate
                $azSpnSecret = $azSecretObject.SecretText
                Write-Verbose "Client secret created successfully."

                # Remove other old secrets
                Write-Verbose "Cleaning up old client secrets..."
                $azAllSecrets = Get-AzADAppCredential -ApplicationId $azSpnAppId
                foreach ($azSecret in $azAllSecrets) {
                    if ($azSecret.KeyId -ne $azSecretObject.KeyId) {
                        Write-Verbose "Removing old client secret with KeyId $($azSecret.KeyId)..."
                        Remove-AzADAppCredential -ApplicationId $azSpnAppId -KeyId $azSecret.KeyId
                    }
                }
                Write-Verbose "Old secrets cleanup completed."
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
                    [string]$azName,
                    [string]$azValue,
                    [string]$azEnv
                )
                Write-Verbose "Creating or updating secret '$azName' for environment '$azEnv'"
                gh secret set $azName --repo "$($ghOrgName)/$($ghRepoName)" --env $azEnv --body $azValue
            }
        
            # Define the secrets and their values
            $azSecrets = @{
                "AZURE_CLIENT_ID"       = $azSpnAppId
                "AZURE_CLIENT_SECRET"   = $azSpnSecret
                "AZURE_SUBSCRIPTION_ID" = $azSubscriptionId
                "AZURE_TENANT_ID"       = (Get-AzContext).Tenant.Id
            }

            foreach ($ghRepo in $ghRepoNames) {
                foreach ($azEnv in $ghEnvNames) {
                    foreach ($azSecretName in $azSecrets.Keys) {
                        $azSecretValue = $azSecrets[$azSecretName]
                        Write-Verbose "Setting secret '$azSecretName' in repo '$ghRepo' for environment '$azEnv'"
                        gh secret set $azSecretName --repo "$($ghOrgName)/$ghRepo" --env $azEnv --body $azSecretValue
                    }
                }
            }

            # Clear the sensitive value from memory
            Write-Verbose "Clearing sensitive values from memory..."
            $azSpnSecret = $null
            $azSecrets["AZURE_CLIENT_SECRET"] = $null
            
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