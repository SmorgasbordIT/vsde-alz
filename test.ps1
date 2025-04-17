$varAzUkAbbrName = 'AZUK'
$varAzUkSouth = 'S'
$varLogAnalyticsAbbrName = 'LAW'
$varLogAnalyticsWorkspaceName = ($varAzUkAbbrName + $varAzUkSouth + '-' + $varLogAnalyticsAbbrName + '-MGT-01').ToUpper()

$varLoggingResourceGroupName = ($varAzUkAbbrName + $varAzUkSouth + '-rg-mgt-log-01').ToUpper()
    

$parLogAnalyticsWorkspaceResourceId = ('/subscriptions/b0017132-8f81-459f-aead-3171c449866f/resourceGroups/{0}/providers/Microsoft.OperationalInsights/workspaces/{1}' -f $varLoggingResourceGroupName.toUpper(),$varLogAnalyticsWorkspaceName.toUpper()).Split('/')[8]
