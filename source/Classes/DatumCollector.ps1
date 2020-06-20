using namespace System.Collections.Specialized

class DatumCollector {
    [string]                    hidden $__Name
    [string]                    hidden $__Description
    [ScriptBlock]               hidden $__When
    [DatumCollectorProvider]    hidden $__DatumCollector
    [string]                    hidden $__Otherwise
    [PSCredential]              hidden $__RunAs
    [OrderedDictionary]         hidden $__Parameters
    [RefreshSchedule]           hidden $__RefreshSchedule
    [OrderedDictionary]         hidden $__Metadata
    [Nullable[DateTime]]        hidden $__LastCollected

    DatumCollector() {
        
    }

    DatumCollector([OrderedDictionary] $DatumCollectorDefinition) {
        $this.__Name = $DatumCollectorDefinition.Name
        $this.__Description = $DatumCollectorDefinition.Description
        $this.__When = [scriptblock]::Create($DatumCollectorDefinition.When)
        $this.__RunAs = if ($null -eq $DatumCollectorDefinition.RunAs)
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
                            
        $this.__Otherwise = $DatumCollectorDefinition.Otherwise
        $this.__RefreshSchedule = if ($null -eq $DatumCollectorDefinition.RefreshSchedule) 
                            {
                                $null
                            }
                            elseif ($DatumCollectorDefinition.RefreshSchedule -is [RefreshSchedule])
                            {
                                $DatumCollectorDefinition.RefreshSchedule
                            }
                            else {
                                Write-Debug "Sending 'RefreshSchedule' to API Dispatcher"
                                [ApiDispatcher]::DispatchSpec('RefreshSchedule', $DatumCollectorDefinition.RefreshSchedule)
                            }
                            
        $this.__Metadata = $DatumCollectorDefinition.Metadata

        if ($DatumCollectorDefinition.DatumCollector.keys -contains 'scriptblock') {
            $this.__DatumCollector = [ApiDispatcher]::DispatchSpec('DatumCollectorScriptBlock',$DatumCollectorDefinition.DatumCollector)
        }
        elseif ($DatumCollectorDefinition.DatumCollector.keys -contains 'Command') {
            $this.__DatumCollector = [ApiDispatcher]::DispatchSpec('DatumCollectorCommand',$DatumCollectorDefinition.DatumCollector)
        }
        elseif ($DatumCollectorDefinition.DatumCollector.keys -contains 'DscResourceName') {
            $this.__DatumCollector = [ApiDispatcher]::DispatchSpec('DatumCollectorDscResource',$DatumCollectorDefinition.DatumCollector)
        }
        else {
            $this.__DatumCollector = [ApiDispatcher]::DispatchSpec('DatumCollectorProvider',$DatumCollectorDefinition.DatumCollector)
        }
    }

    [object] Collect() {
        # TODO #1: Evaluate the When first, and run Collect or return Otherwise || $null
        $result = $this.__DatumCollector.Collect()
        $this.SetResultProperties($result)
        return $result
    }

    [object] GetValue() {
        if (-not $this.__LastCollected) {
            $null = $this.Collect()
            $this.__LastCollected = [datetime]::Now
        }

        return $this
    }

    
    hidden [void] SetResultProperties($Result) {
        $Result.PSObject.Properties | ForEach-Object {
            try {
                $this | Add-Member -MemberType NoteProperty -Value $_.Value -Name $_.Name -Force
            }
            catch {
                Throw "Error trying to update property $($_.Name) of current Object"
            }
        }
    }
}