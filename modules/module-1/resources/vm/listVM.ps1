workflow Get-AzureVM
{
    Disable-AzContextAutosave -Scope Process
    $AzureContext = (Connect-AzAccount -Identity -AccountId REPLACE_CLIENT_ID).context
	$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext


    $VMs = Get-AzVM -ResourceGroupName REPLACE_RESOURCE_GROUP_NAME

    
	Write-Output "Finding VM"
    
	Write-Output $VMs[0]
    
}