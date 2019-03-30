<#
.SYNOPSIS
    Copies a collection of APIM operations from one API to another.

.NOTES
	Use Add-AzureAccount command to login to Azure account.  See link below for details.

.LINK
	https://redmondmag.com/articles/2016/01/25/connect-to-microsoft-azure-with-powershell.aspx
#>
[string]$apimResourceGroupName = "ttaylorskylinergdev01"
[string]$apimServiceName = "ttaylorskylineapimdev01"
[string]$apiNameFrom = "contacts-api"
[string]$apiNameTo = "users-api"
[string[]]$operationNamesToMove = `
	"create-contact",`
	"delete-contact", `
	"modify-contact"

<#
.SYNOPSIS
	Copies a single APIM operation from the 'From' API to the 'To' API.

.PARAMETER ApimContext
	Instance of APIM for performaning actions against.

.PARAMETER Operation
	Object representation of the APIM operation to be copied.

.PARAMETER ApiNameFrom
	APIM API name from which operations will be copied from.

.PARAMETER ApiNameTo
	APIM API name from which operations will be copied to.

#>
function Copy-OperationToApi {
    Param(
        [Parameter(Mandatory = $true, 
			HelpMessage = "The API Management context object.")]
		[object] 
		$ApimContext, 
        
		[Parameter(Mandatory = $true, 
			HelpMessage = "The operation object that will be copied.")]
		[object] 
		$Operation, 
        
		[Parameter(Mandatory = $true, 
			HelpMessage = "The name of the API where the operations will be copied from.")]
        [ValidateNotNullOrEmpty()]
		[string] 
		$ApiNameFrom, 
	    
		[Parameter(Mandatory = $true, 
			HelpMessage = "The name of the API where the operations will be copied to.")]
        [ValidateNotNullOrEmpty()]
		[string] 
		$ApiNameTo
	)
    
	# If the description is greater than 1000 characters, use filler text and log a warning.
    if ($Operation.Description.Length -gt 1000)
    {
        $Operation.Description = "<TODO>"
        Write-Host "WARNING: Description for operation '$Operation.Name' exceeded 1000 characters `
					and was not updated." -ForegroundColor Red
    }

    $existingOperation = Get-AzureRmApiManagementOperation `
		-Context $ApimContext `
		-ApiId $ApiNameTo `
		-OperationId $Operation.OperationId `
		-Erroraction SilentlyContinue
    
    if ($existingOperation -eq $null) 
    {    
        New-AzureRmApiManagementOperation `
            -Context $ApimContext `
            -ApiId $ApiNameTo `
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
		-ApiId $ApiNameFrom `
		-OperationId $Operation.OperationId `
		-Erroraction SilentlyContinue

    if ($existingPolicy -eq $null) 
    {    
		Set-AzureRmApiManagementPolicy `
			-Context $ApimContext `
			-ApiId $ApiNameTo `
			-OperationId $Operation.OperationId `
			-Policy $existingPolicy `
			-ErrorAction SilentlyContinue
	}
}

<#
.SYNOPSIS
	Loops through a collection of APIM operation names (operation IDs) and copies each 
	operation from the 'From' API to the 'To' API.

.PARAMETER ApimContext
	Instance of APIM for performaning actions against.

.PARAMETER OperationNames
	Array of strings consisting of the APIM operation names to be copied.

.PARAMETER ApiNameFrom
	APIM API name from which operations will be copied from.

.PARAMETER ApiNameTo
	APIM API name from which operations will be copied to.

#>
function Copy-OperationsToApi {
	Param(
		[Parameter(Mandatory = $true, 
			HelpMessage = "The API Management context object.")]
		[object] 
		$ApimContext, 

		[Parameter(Mandatory = $true, 
			HelpMessage = "One or more operation names separated by commas.")]
		[ValidateNotNullOrEmpty()]
		[string[]] 
		$OperationNames, 
		
		[Parameter(Mandatory = $true, 
			HelpMessage = "The ID of the API where the operations will be copied from.")]
        [ValidateNotNullOrEmpty()]
		[string] 
		$ApiNameFrom, 
	
		[Parameter(Mandatory = $true, 
			HelpMessage = "The ID of the API where the operations will be copied to.")]
        [ValidateNotNullOrEmpty()]
		[string] 
		$ApiNameTo
	)

	foreach ($operationName in $OperationNames) 
	{
		$operation = Get-AzureRmApiManagementOperation `
			-Context $ApimContext `
			-ApiId $ApiNameFrom `
			-OperationId $operationName `
			-Erroraction SilentlyContinue
		
		Copy-OperationToApi `
			-ApimContext $ApimContext `
			-Operation $operation `
			-ApiNameFrom $ApiNameFrom `
			-ApiNameTo $ApiNameTo
	}
}

$apimContext = New-AzureRmApiManagementContext `
	-ResourceGroupName $apimResourceGroupName `
	-ServiceName $apimServiceName

Copy-OperationsToApi `
	-OperationNames $operationNamesToMove `
	-ApimContext $apimContext `
	-ApiNameFrom $apiNameFrom `
	-ApiNameTo $apiNameTo