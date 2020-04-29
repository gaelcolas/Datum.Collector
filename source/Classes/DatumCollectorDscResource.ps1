class DatumCollectorDscResource : DatumCollectorProvider {
    [string]                     $DscResourceName
    [string]                     $Verbose
    
    [DscResourceCollectorMethod] $DscResourceCollectorMethod = [DscResourceCollectorMethod]::Get

    DatumCollectorDscResource ($DatumCollectorDscResourceDefinition) {
        $this.Set_ModuleFromDefinition($DatumCollectorDscResourceDefinition)
        $this.Set_ParametersFromDefinition($DatumCollectorDscResourceDefinition)
        $this.DscResourceName = $DatumCollectorDscResourceDefinition.ResourceName
    }

    # Get the DSC Resource specified
    # Find out whether the Resource has a Sub-type(s)
    # If there's a subtype, create CimInstance(s) for it based on Parameter

    [Object] Collect() {
        #Invoke-DscResource -name -Method -Verbose -ModuleName -Property
        return @{}
    }

    [Object] Collect([System.Collections.IDictionary] $Parameters) {
        return @{}
    }
}