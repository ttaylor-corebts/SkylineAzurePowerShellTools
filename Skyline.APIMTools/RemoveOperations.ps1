<# 
.SYNOPSIS
    Removes a collection of APIM operations from a specified API.

.NOTES
	Use Add-AzureAccount command to login to Azure account.  See link below for details.

.LINK
	https://redmondmag.com/articles/2016/01/25/connect-to-microsoft-azure-with-powershell.aspx
#>
[string]$apimResourceGroupName = "ttaylorskylinergdev01"
[string]$apimServiceName = "ttaylorskylineapimdev01"
[string]$apiName = "contacts-api"
[string[]]$operationNamesToRemove = `
	"create-contact",`
	"delete-contact", `
	"modify-contact"

<#
.SYNOPSIS
	Loops through a collection of APIM operation IDs and removes each operation from the 
	defined API.

.PARAMETER ApimContext
	Instance of APIM for performaning actions against.

.PARAMETER OperationIds
	Array of strings consisting of the APIM operation names to be removed.

.PARAMETER ApiName
	APIM API name from which operations will be removed.

#>
function Remove-OperationsFromApi {
	Param(
		[Parameter(Mandatory = $true, 
			HelpMessage = "The API Management context object.")]
		[object]
		$ApimContext, 

		[Parameter(Mandatory = $true, 
			HelpMessage = "One or more operation names separated by commas.")]
		[ValidateNotNullOrEmpty()]
		[string[]] 
		[string[]]
		$OperationNames, 
		
		[Parameter(Mandatory = $true, 
			HelpMessage = "The name of the API where the operations will be removed from.")]
        [ValidateNotNullOrEmpty()]
		[string]
		$ApiName
	)

	foreach ($operationName in $OperationNames) 
	{
		Remove-AzureRmApiManagementOperation `
			-Context $ApimContext `
			-ApiId $ApiName `
			-OperationId $operationName `
			-ErrorAction SilentlyContinue

		Write-Host "Successfully removed operation '$operationName' from API '$ApiName'." -ForegroundColor Green
	}
}

$apimContext = New-AzureRmApiManagementContext `
	-ResourceGroupName $apimResourceGroupName `
	-ServiceName $apimServiceName

Remove-OperationsFromApi `
	-ApimContext $apimContext `
	-OperationNames $operationNamesToRemove `
	-ApiName $apiName