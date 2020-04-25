class DatumCollectorCommand : DatumCollectorProvider {
    [System.Management.Automation.CommandInfo] $Command

    DatumCollectorCommand ([orderedDictionary] $DatumCollectorCommandDefinition) {

        if ($DatumCollectorCommandDefinition.Command.Keys -contains 'kind') {
            $this.Command = [ApiDispatcher]::DispatchSpec($DatumCollectorCommandDefinition.Command)
        }
        else {
            $this.Command = Get-Command $DatumCollectorCommandDefinition.Command -ErrorAction Stop
        }

        $this.Set_ModuleFromDefinition($DatumCollectorCommandDefinition)
        $this.Set_ParametersFromDefinition($DatumCollectorCommandDefinition)
    }

    [Object] Collect() {
        if ($this.Parameters) {
            return $this.Collect($this.Parameters)
        }
        else {
            return &$this.Command
        }
    }

    [Object] Collect([System.Collections.IDictionary] $params) {
        if ($this.Module) {
            Import-Module -FullyQualifiedName $this.Module
        }
        Write-Debug "Invoking command '$($this.Command.Name)' with splatting params (keys: $($params.keys -join ', '))"
        return &$this.Command @params
    }

    [Object] Collect([System.Collections.IEnumerable] $Parameter) {
        if ($this.Module) {
            Import-Module -FullyQualifiedName $this.Module
        }
        Write-Debug "Invoking command '$($this.Command.Name)' with param array (positional)"
        return &$this.Command $Parameter
    }
}