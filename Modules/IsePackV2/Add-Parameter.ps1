function Add-Parameter {
    <#
    .Synopsis
        Adds a Parameter attribute to the current file in the ISE
    .Description
        Adds a Parameter attribute to the current file in the ISE
    .Example
        Add-Parameter    #>
    param(
        #The name of the parameter
        [Parameter(Position=0)]
        [string]$Name,

        #The name of the parameter
        [Parameter(Position=1)]
        [string]$ParameterType,
        # If set, will add a ParameterSetName ot the parameter attribute
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=2)]		
		[String]$ParameterSet,
        # If set, will add a HelpMessage to the parameter attribute
		[Parameter(ValueFromPipelineByPropertyName=$true,Position=3)]
        [String]$HelpMessage,
        # If Set, the parameter attribute will be marked as mandatory
		[Parameter(ValueFromPipelineByPropertyName=$true,Position=4)]
        [Switch]$Mandatory,
        # If Set, the parameter attribute will be marked to accept pipeline input
		[Parameter(ValueFromPipelineByPropertyName=$true,Position=5)]
        [Switch]$FromPipeline,
        # If set, the parameter attribute will be marked to accept input from
        # the pipeline by property name
		[Parameter(ValueFromPipelineByPropertyName=$true,Position=6)]
        [Switch]$FromPipelineByPropertyName,
		# IF set, the parameter attribut will use this position
		[Parameter(ValueFromPipelineByPropertyName=$true,Position=7)]
		[int]$Position,		
		# If set, will add aliases to the parameter
		[Parameter(ValueFromPipelineByPropertyName=$true,Position=8)]
        [Alias('Aliases')]
		[String[]]$Alias,
		
		[Parameter(ValueFromPipelineByPropertyName=$true,Position=9)]
		[Switch]$OutputText
    ) 
	
	process {
	
	    $parameterText = "[Parameter("
	    if ($ParameterSet) {
	        $ParameterText += "ParameterSetName='$ParameterSet',"
	    }
	    if ($Mandatory) {
	        $ParameterText += 'Mandatory=$true,'
	    }
	    if ($FromPipeline) { 
	        $ParameterText += 'ValueFromPipeline=$true,'
	    }
	    if ($FromPipelineByPropertyName) { 
	        $ParameterText += 'ValueFromPipelineByPropertyName=$true,'
	    }

        if ($ParameterType) {
            $ParameterType = $ParameterType.Trim("[]")
        }
        if (-not $ParameterType) {
            $ParameterType = "PSObject"
        }
            
	    if ($HelpMessage) {
	        $ParameterText += "HelpMessage='$HelpMessage',"
			$parameterText = "
<#
$HelpMessage
#>
[$ParameterType]
$ParameterText"
	    }
		if ($psBoundParameters.Position) {
			$ParameterText += "Position='$Position',"
		}

		$ParameterText = $ParameterText.TrimEnd(",") + ")]"
		if ("$Alias".Trim()) {
			$OFS = "','"
			$parameterText+=@"
[Alias('$Alias')]
"@
		}
	
		if ($OutputText) {
            if ($Name) {
                "$ParameterText
                `$$name
                "
            } else {
                "$ParameterText
                "
            }
			
		} else {
            if ($Name) {
                Add-TextToCurrentDocument -Text "$ParameterText
`$$name,
"
            } else {
                Add-TextToCurrentDocument -Text "$ParameterText
"
            }			
		}
		
	
	}
}