class DatumCollectorProvider {

    [Microsoft.PowerShell.Commands.ModuleSpecification] $Module
    [System.Collections.IDictionary] $Parameters

    [void] Collect()
    {
        Throw "This class should not be instanciated directly."
    }

    hidden [void] Set_ParametersFromDefinition($DatumCollectorProviderDefinition) {
        Write-Debug "Resolving Datum Collector Parameters"
        if ($definedParameters = $DatumCollectorProviderDefinition.Parameters) {
            $this.Parameters = [ordered]@{}
            foreach ($ParamKey in $definedParameters.keys) {
                if ($definedParameters.($ParamKey).keys -contains 'kind') {
                    Write-Debug "Resolving parameter '$ParamKey' of kind '$($definedParameters.($ParamKey).kind)'"
                    $this.Parameters.Add($ParamKey, [ApiDispatcher]::DispatchSpec($definedParameters.($ParamKey)))
                }
                else {
                    Write-Debug "Adding '$ParamKey' of type '[$($definedParameters.($ParamKey).GetType().ToString())]'"
                    $this.Parameters.Add($ParamKey, $definedParameters.($ParamKey))
                }
            }
        }
        else {
            Write-Debug "There are no Paramaters for this Collector"
        }
    }

    hidden [void] Set_ModuleFromDefinition($DatumCollectorProviderDefinition) {
        if ([string]::IsNullOrEmpty($DatumCollectorProviderDefinition.Module)) {
            Write-Debug "No module defined for this Datum Collector Provider"
        }
        elseif ($DatumCollectorProviderDefinition -is [string]) {
            $this.Module = [Microsoft.PowerShell.Commands.ModuleSpecification]::new($DatumCollectorProviderDefinition.Module)
        }
        elseif($DatumCollectorProviderDefinition.keys -notcontains 'spec') {
            $this.Module = [Microsoft.PowerShell.Commands.ModuleSpecification]::new($DatumCollectorProviderDefinition.Module)
        }
        else {
            $this.Module = [ApiDispatcher]::DispatchSpec('Microsoft.PowerShell.Commands.ModuleSpecification', $DatumCollectorProviderDefinition.Module)
        }
    }
}