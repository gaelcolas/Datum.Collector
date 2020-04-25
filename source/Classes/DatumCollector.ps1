using namespace System.Collections.Specialized

class DatumCollector {
    [string]                    $Name
    [string]                    $Description
    [ScriptBlock]               $When
    [DatumCollectorProvider]    $DatumCollector
    [string]                    $Otherwise
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
                                Write-Debug "Sending 'RunAs' to API Dispatcher"
                                [ApiDispatcher]::DispatchSpec('DatumHandler',$DatumCollectorDefinition.RunAs)
                            }
                            
        $this.Otherwise = $DatumCollectorDefinition.Otherwise
        $this.RefreshSchedule = if ($null -eq $DatumCollectorDefinition.RefreshSchedule) 
                            {
                                $null
                            }
                            elseif ($DatumCollectorDefinition.RefreshSchedule -is [Schedule])
                            {
                                $DatumCollectorDefinition.RefreshSchedule
                            }
                            else {
                                Write-Debug "Sending 'RefreshSchedule' to API Dispatcher"
                                [ApiDispatcher]::DispatchSpec('Schedule', $DatumCollectorDefinition.RefreshSchedule)
                            }
                            
        $this.Metadata = $DatumCollectorDefinition.Metadata

        if ($DatumCollectorDefinition.DatumCollector.keys -contains 'scriptblock') {
            $this.DatumCollector = [ApiDispatcher]::DispatchSpec('DatumCollectorScriptBlock',$DatumCollectorDefinition.DatumCollector)
        }
        elseif ($DatumCollectorDefinition.DatumCollector.keys -contains 'Command') {
            $this.DatumCollector = [ApiDispatcher]::DispatchSpec('DatumCollectorFunction',$DatumCollectorDefinition.DatumCollector)
        }
        elseif ($DatumCollectorDefinition.DatumCollector.keys -contains 'DscResourceName') {
            $this.DatumCollector = [ApiDispatcher]::DispatchSpec('DatumCollectorDscResource',$DatumCollectorDefinition.DatumCollector)
        }
        else {
            $this.DatumCollector = [ApiDispatcher]::DispatchSpec('DatumCollectorProvider',$DatumCollectorDefinition.DatumCollector)
        }
    }

    [object] Collect() {
        $this.DatumCollector.Collect()
    }
}