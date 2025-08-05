## This script is derived from the original by Jack Tracey, which you can find here: 
## https://github.com/jtracey93/PublicScripts/blob/master/Azure/PowerShell/Enterprise-scale/Wipe-ESLZAzTenant.ps1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Insert the Tenant ID (GUID) of your Microsoft Entra tenant. E.g. 'f73a2b89-6c0e-4382-899f-ea227cd6b68f'")]
    [ValidatePattern('^[0-9a-fA-F\-]{36}$')]
    [string]$azTenantRootGroupID = 'ec5f282f-1669-4a4b-b01f-120c7c8e8acf',

    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Insert the name of your intermediate root Management Group. E.g. 'AZUK-SBIT'")]
    [ValidateNotNullOrEmpty()]
    [string]$azIntermediateRootGroupID = 'azuk-sbit',

    [Parameter(Mandatory = $true, Position = 3, HelpMessage = "Insert the subscription ID for the Management subscription.")]
    [ValidatePattern('^[0-9a-fA-F\-]{36}$')]
    [string]$azManagementSubId = 'b0017132-8f81-459f-aead-3171c449866f',

    [Parameter(Mandatory = $true, Position = 4, HelpMessage = "Insert the subscription ID for the Identity subscription.")]
    [ValidatePattern('^[0-9a-fA-F\-]{36}$')]
    [string]$azIdentitySubId = '35bc190f-74f7-4adb-aa1e-2bd3b45e9ffb',

    [Parameter(Mandatory = $true, Position = 5, HelpMessage = "Insert the subscription ID for the Connectivity subscription.")]
    [ValidatePattern('^[0-9a-fA-F\-]{36}$')]
    [string]$azConnectivitySubId = '418b1b0c-5109-4c71-b3ec-bb2aede68fb5',

    [Parameter(Position = 6, HelpMessage = "Wildcard or specific name(s) of Resource Groups to target. E.g. 'rg-*'")]
    [string]$azRgNames = "*",

    [Parameter(Position = 8, HelpMessage = "Wildcard or specific name(s) of Deployments to target. E.g. 'deploy-*'")]
    [string]$azDeploymentNames = "*",

    [Parameter(Position = 99, HelpMessage = "If set to `$true`, the script will give you a Deploy Stage Warning.")]
    [bool]$WhatIfEnabled = $true
)

if($whatIfEnabled) {
    Write-Warning "⚠️ - Deploy Stage Warning:"
    Write-Warning "This operation will ** permanently delete all components ** of your landing zone."
    Write-Warning "This includes ** every resource ** within your platform subscriptions."
    Write-Warning "Ensure you have backed up any data you need to retain before proceeding."

    Write-Warning ""
    Write-Warning "🚨 DANGER ZONE: IRREVERSIBLE ACTION 🚨"
    Write-Warning "Do NOT approve this run unless you are absolutely certain you intend to destroy all resources."
    exit 0
} else {
    # User explicitly set whatIfEnabled = $false
    # Exit silently without doing anything
    return
}

$azManGrps = Get-AzManagementGroup
$azManGrp = $azManGrps | Where-Object { $_.Name -eq $azIntermediateRootGroupID }
if($null -eq $azManGrp) {
    Write-Warning "The $azIntermediateRootGroupID does not exist, so there is nothing to delete."
    exit 0
}

if ($azTenantRootGroupID -eq "") {
    $azTenantRootGroupID = (Get-AzContext).Tenant.TenantId
}
$azResetMdfcTierOnSubs = $true

# Toggle to stop warnings with regards to DisplayName and DisplayId
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

# Start timer
$azStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$azStopWatch.Start()

# Get all Subscriptions that are in the Intermediate Root Management Group's hierarchy tree
$azIntermediateRootGroupChildSubs = Search-AzGraph -Query "resourcecontainers | where type =~ 'microsoft.resources/subscriptions' | mv-expand mgmtGroups=properties.managementGroupAncestorsChain | where mgmtGroups.name =~ '$azIntermediateRootGroupID' | project subName=name, subID=subscriptionId, subState=properties.state, aadTenantID=tenantId, mgID=mgmtGroups.name, mgDisplayName=mgmtGroups.displayName"

Write-Output "Moving all subscriptions under root management group"

# For each Subscription in Intermediate Root Management Group's hierarchy tree, move it to the Tenant Root Management Group
$azIntermediateRootGroupChildSubs | ForEach-Object -Parallel {
    # The name 'Tenant Root Group' doesn't work. Instead, use the GUID of your Tenant Root Group
    if ($_.subState -ne "Disabled") {
        Write-Output "Moving Subscription: '$($_.subName)' under Tenant Root Management Group: '$($using:azTenantRootGroupID)'"
        New-AzManagementGroupSubscription -GroupId $using:azTenantRootGroupID -SubscriptionId $_.subID | Out-Null
    }
}

# For each Subscription in the Intermediate Root Management Group's hierarchy tree, remove all Resources, Resource Groups and Deployments
Write-Output "Removing all Azure Resources, Resource Groups and Deployments from Subscriptions in scope"

$azSubsToClean = @()
ForEach ($azSubs in $azIntermediateRootGroupChildSubs) {
    $azSubsToClean += @{
        name = $azSubs.subName
        id   = $azSubs.subID
    }
}

$azSubIds = $azSubsToClean | Select-Object -ExpandProperty id

if($azSubIds -notcontains $azManagementSubId) {
    $azSubsToClean += @{
        name = "Management"
        id   = $azManagementSubId
    }
    $azSubIds += $azManagementSubId
}

if($azSubIds -notcontains $azIdentitySubId) {
    $azSubsToClean += @{
        name = "Identity"
        id   = $azIdentitySubId
    }
    $azSubIds += $azIdentitySubId
}

if($azSubIds -notcontains $azConnectivitySubId) {
    $azSubsToClean += @{
        name = "Connectivity"
        id   = $azConnectivitySubId
    }
    $azSubIds += $azConnectivitySubId
}

if($azSubIds -notcontains $azSharedSubId) {
    $azSubsToClean += @{
        name = "Shared"
        id   = $azSharedSubId
    }
    $azSubIds += $azSharedSubId
}

ForEach ($azSubs in $azSubsToClean) {
    Write-Output "Set context to Subscription: '$($azSubs.name)'"
    Set-AzContext -Subscription $azSubs.id | Out-Null

    # === User Confirmation Before Deleting All Resource Groups in Subscription ===
    Write-Warning "This will delete ALL resource groups in subscription: $(Get-AzContext).Subscription.Name"
    $azConfirm = Read-Host "Type YES to continue"
    if ($azConfirm -ne "YES") {
        Write-Warning "Aborted by user."
        exit
    }

    # Get all Resource Groups in Subscription
    $azResGroups = Get-AzResourceGroup

    $azResGroupsToRemove = @()
    ForEach ($azResGroup in $azResGroups) {
        if ($azResGroup.ResourceGroupName -like $azRgNames) {
            $azResGroupsToRemove += $azResGroup.ResourceGroupName
        }
    }

    $azResGroupsToRemove | ForEach-Object -Parallel {
        Write-Output "Deleting $_..."
        Remove-AzResourceGroup -Name $_ -Force | Out-Null
    }

    # Get Deployments for Subscription
    $azSubDeployments = Get-AzSubscriptionDeployment

    Write-Output "Removing All Successful Subscription Deployments for: $($azSubs.name)"

    $azDeploymentsToRemove = @()
    ForEach ($azDeployment in $azSubDeployments) {
        if ($azDeployment.DeploymentName -like $azDeploymentNames -and $azDeployment.ProvisioningState -eq "Succeeded") {
            $azDeploymentsToRemove += $azDeployment
        }
    }

    # For each Subscription level deployment, remove it
    $azDeploymentsToRemove | ForEach-Object -Parallel {
        Write-Output "Removing $($_.DeploymentName) ..."
        Remove-AzSubscriptionDeployment -Id $_.Id | Out-Null
    }

    # Set MDFC tier to Free for each Subscription
    if ($azResetMdfcTierOnSubs) {
        Write-Output "Resetting MDFC tier to Free for Subscription: $($azSubs.name)"

        $azCurrentMdfcForSubUnfiltered = Get-AzSecurityPricing
        $azCurrentMdfcForSub = $azCurrentMdfcForSubUnfiltered | Where-Object { $_.PricingTier -ne "Free" }

        ForEach ($azMdfcPricingTier in $azCurrentMdfcForSub) {
            Write-Output "Resetting $($azMdfcPricingTier.Name) to Free MDFC Pricing Tier for Subscription: $($azSubs.name)"

            Set-AzSecurityPricing -Name $azMdfcPricingTier.Name -PricingTier 'Free' | Out-Null
        }
    }
}

# This function deletes only the Management Groups within the hierarchy of the specified Intermediate Root Management Group.
# It does NOT affect other top-level (peer) Intermediate Root Management Groups or their descendants — e.g., "canary".

function Remove-Recursively {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$name
    )
    if($PSCmdlet.ShouldProcess($name, "Remove-AzManagementGroup")) {
        # Enters the parent Level
        Write-Output "Entering the scope with $name"
        $parent = Get-AzManagementGroup -GroupId $name -Expand -Recurse

        # Checks if there is any parent level
        if ($null -ne $parent.Children) {
            Write-Output "Found the following Children :"
            Write-Output ($parent.Children | Select-Object Name).Name

            foreach ($children in $parent.Children) {
                # Tries to recur to each child item
                Remove-Recursively($children.Name)
            }
        }

        # If no children are found at each scope
        Write-Output "No children found in scope $name"
        Write-Output "Removing the scope $name"

        Remove-AzManagementGroup -InputObject $parent | Out-Null
    }
}

# Check if Management Group exists for idempotency
$azManGrps = Get-AzManagementGroup
$azManGrp = $azManGrps | Where-Object { $_.Name -eq $azIntermediateRootGroupID }

if($null -eq $azManGrp) {
    Write-Output "Management Group with ID: '$azIntermediateRootGroupID' does not exist."
} else {
    Write-Output "Management Group with ID: '$azIntermediateRootGroupID' exists. Proceeding with deletion."

    # Remove all the Management Groups in Intermediate Root Management Group's hierarchy tree, including itself
    Remove-Recursively($azIntermediateRootGroupID)
}

# Stop timer
$azStopWatch.Stop()

# Display timer output as table
Write-Output "Time taken to complete task:"
$azStopWatch.Elapsed | Format-Table
