<#
.SYNOPSIS
	Copies a single APIM operation from the 'From' API to the 'To' API.

.PARAMETER ApimContext
	Instance of APIM for performaning actions against.

.PARAMETER Operation
	Object representation of the APIM operation to be copied.

.PARAMETER ApiIdFrom
	APIM API identifier from which operations will be copied from.

.PARAMETER ApiIdTo
	APIM API identifier from which operations will be copied to.

#>
function Copy-OperationToApi
{
    Param([object] $ApimContext, [object] $Operation, [string] $ApiIdFrom, [string] $ApiIdTo)
    
    if ($Operation.Description.Length -gt 1000)
    {
        $Operation.Description = "<TODO>"
        Write-Host "WARNING: Description for operation '$Operation.Name' exceeded 1000 characters and was not updated." -ForegroundColor Red
    }

    $existingOperation = Get-AzureRmApiManagementOperation `
		-Context $ApimContext `
		-ApiId $ApiIdTo `
		-OperationId $Operation.OperationId `
		-Erroraction SilentlyContinue
    
    if ($existingOperation -eq $null) 
    {    
        New-AzureRmApiManagementOperation `
            -Context $ApimContext `
            -ApiId $ApiIdTo `
            -OperationId $Operation.OperationId `
            -Name $Operation.Name `
            -Method $Operation.Method `
            -UrlTemplate $Operation.UrlTemplate `
            -Description $Operation.Description `
            -TemplateParameters $Operation.TemplateParameters `
            -Request $Operation.Request `
            -Responses $Operation.Responses 
    }

    $existingPolicy = Get-AzureRmApiManagementPolicy `
		-Context $ApimContext `
		-ApiId $ApiIdFrom `
		-OperationId $Operation.OperationId `
		-Erroraction SilentlyContinue

    if ($existingPolicy -eq $null) 
    {    
		Set-AzureRmApiManagementPolicy `
			-Context $ApimContext `
			-ApiId $ApiIdTo `
			-OperationId $Operation.OperationId `
			-Policy $existingPolicy `
			-ErrorAction SilentlyContinue
	}
}

<#
.SYNOPSIS
	Loops through a collection of APIM operation IDs and copies each operation from the 
	'From' API to the 'To' API.

.PARAMETER ApimContext
	Instance of APIM for performaning actions against.

.PARAMETER OperationIds
	Array of strings consisting of the APIM operation names to be copied.

.PARAMETER ApiIdFrom
	APIM API identifier from which operations will be copied from.

.PARAMETER ApiIdTo
	APIM API identifier from which operations will be copied to.

#>
function Copy-OperationsToApi
{
	Param([object] $ApimContext, [object[]] $OperationIds, [string] $ApiIdFrom, [string] $ApiIdTo)

	foreach ($operationId in $OperationIds) 
	{
		$operation = Get-AzureRmApiManagementOperation `
			-Context $apiMgmtContext `
			-ApiId $apiIdFrom `
			-OperationId $operationId `
			-Erroraction SilentlyContinue
		
		Copy-OperationToApi `
			-ApimContext $apiMgmtContext `
			-Operation $operation `
			-ApiIdFrom $apiIdFrom `
			-ApiIdTo $apiIdTo
	}
}

<#
.SYNOPSIS
    Copies a collection of APIM operations from one API to another.

.NOTES
	Use Add-AzureAccount command to login to Azure account.  See link below for details.

.LINK
	https://redmondmag.com/articles/2016/01/25/connect-to-microsoft-azure-with-powershell.aspx
#>

$apimResourceGroupName = "ttaylorskylinergdev01"
$apimServiceName = "ttaylorskylineapimdev01"
$apiIdFrom = "contacts-api"
$apiIdTo = "users-api"
$operationIdsToMove = "get-contact" # Can be array of 1 or more strings

$apiMgmtContext = New-AzureRmApiManagementContext `
	-ResourceGroupName $apimResourceGroupName `
	-ServiceName $apimServiceName

Copy-OperationsToApi `
	-OperationIds $operationIdsToMove `
	-ApimContext $apiMgmtContext `
	-ApiIdFrom $apiIdFrom `
	-ApiIdTo $apiIdTo