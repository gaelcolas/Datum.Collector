using namespace System.Collections.Specialized

class DatumCollector {
    [string]                    $Name
    [string]                    $Description
    [ScriptBlock]               $When
    [DatumCollectorProvider]    $DatumCollector
    # [Nullable[string]]          $Otherwise
    [PSCredential]              $RunAs
    [OrderedDictionary]         $Parameters
    [Schedule]                  $RefreshSchedule
    [OrderedDictionary]         $Metadata

    DatumCollector() {
        
    }

    DatumCollector([OrderedDictionary] $DatumCollectorDefinition) {
        $this.Name = $DatumCollectorDefinition.Name
        $this.Description = $DatumCollectorDefinition.Description
        $this.When = [scriptblock]::Create($DatumCollectorDefinition.When)
        $this.RunAs = if ($null -eq $DatumCollectorDefinition.RunAs) 
                            {
                                $null
                            }
                            elseif ($DatumCollectorDefinition.RunAs -is [pscredential])
                            {
                                $DatumCollectorDefinition.RunAs
                            }
                            else {
                                [ApiDispatcher]::DispatchSpec('DatumHandler',$DatumCollectorDefinition.RunAs)
                            }
                            
        
    }
}