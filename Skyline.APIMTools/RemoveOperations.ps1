<#
.SYNOPSIS
	Loops through a collection of APIM operation IDs and removes each operation from the 
	defined API.

.PARAMETER ApimContext
	Instance of APIM for performaning actions against.

.PARAMETER OperationIds
	Array of strings consisting of the APIM operation names to be removed.

.PARAMETER ApiId
	APIM API identifier from which operations will be removed.

#>
function Remove-OperationsFromApi
{
	Param(
		[object] $ApimContext, 
		[object[]] $OperationIds, 
		[string] $ApiId)

	foreach ($operationId in $OperationIds) 
	{
		Remove-AzureRmApiManagementOperation `
			-Context $apiMgmtContext `
			-ApiId $ApiId `
			-OperationId $OperationId `
			-ErrorAction SilentlyContinue

		Write-Host "Successfully removed operation '$OperationId' from API '$ApiId'." -ForegroundColor Green
	}
}

<# 
.SYNOPSIS
    Removes a collection of APIM operations from a specified API.

.NOTES
	Use Add-AzureAccount command to login to Azure account.  See link below for details.

.LINK
	https://redmondmag.com/articles/2016/01/25/connect-to-microsoft-azure-with-powershell.aspx
#>
$apimResourceGroupName = "ttaylorskylinergdev01"
$apimServiceName = "ttaylorskylineapimdev01"
$apiId = "users-api"
$operationIdsToRemove = "get-contact" # Can be array of 1 or more strings

$apiMgmtContext = New-AzureRmApiManagementContext `
	-ResourceGroupName $apimResourceGroupName `
	-ServiceName $apimServiceName

Remove-OperationsFromApi `
	-ApimContext $apiMgmtContext `
	-OperationIds $operationIdsToRemove `
	-ApiId $apiId