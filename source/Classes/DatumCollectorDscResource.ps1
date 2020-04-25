class DatumCollectorDscResource : DatumCollectorProvider {
    [string]                     $DscResourceName
    [DscResourceCollectorMethod] $DscResourceCollectorMethod = [DscResourceCollectorMethod]::Get

    DatumCollectorDscResource ($DatumCollectorDscResourceDefinition) {
        $this.Set_ModuleFromDefinition($DatumCollectorDscResourceDefinition)
        $this.Set_ParametersFromDefinition($DatumCollectorDscResourceDefinition)
        $this.DscResourceName = $DatumCollectorDscResourceDefinition.ResourceName
    }

    [Object] Collect() {
        return @{}
        #Invoke-DscResource -name -Method -Verbose -ModuleName -Property
    }

    [Object] Collect([System.Collections.IDictionary] $Parameters) {
        return @{}
    }
}