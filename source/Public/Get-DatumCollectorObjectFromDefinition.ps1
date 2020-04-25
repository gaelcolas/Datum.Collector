function Get-DatumCollectorObjectFromDefinition {
    [CmdletBinding(DefaultParameterSetName= 'ByPath')]
    param (
        [Parameter(ParameterSetName = 'ByPath', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        
        
        [Parameter(ParameterSetName = 'ByDictionary', Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.IDictionary[]]
        $Definition,

        [string]
        $DefaultType
    )
    
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'ByPath') {
            $Definition = foreach ($pathItem in $Path) {
                $files = if (Test-Path -Path $pathItem -PathType Container) {
                    # This is NOT recursive
                    Get-ChildItem -Path $pathItem -File -Include *.yml
                }
                else {
                    $pathItem
                }

                $files.foreach{
                    Get-Content -Raw -Path $_ | ConvertFrom-Yaml -AllDocuments -Ordered
                }
            }
        }
    }
    
    process {
        foreach ($objectDefinition in $Definition) {
            if ($DefaultType) {
                [ApiDispatcher]::DispatchSpec($DefaultType, $objectDefinition)
            }
            else {
                [ApiDispatcher]::DispatchSpec($objectDefinition)
            }
        }
    }
    
    end {
        
    }
}