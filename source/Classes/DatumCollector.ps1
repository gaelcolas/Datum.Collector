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
    }
}