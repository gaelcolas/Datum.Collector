using namespace System.Collections.Specialized
class DatumCollectorScriptblock : DatumCollectorProvider {
    [scriptblock] hidden $ScriptBlock
    [System.Collections.IDictionary] hidden $Parameters

    DatumCollectorScriptblock ([orderedDictionary] $DatumCollectorScriptblockDefinition) {
        $scriptblockDefinition = $DatumCollectorScriptblockDefinition.scriptblock.Trim()
        if ($scriptblockDefinition -match '^\{[\w\W]*\}$') {
            $scriptblockDefinition = $scriptblockDefinition.Trim(@('{','}'))
        }
        $this.ScriptBlock = [scriptblock]::Create($scriptblockDefinition)
        $this.Set_ModuleFromDefinition($DatumCollectorScriptblockDefinition)
        $this.Set_ParametersFromDefinition($DatumCollectorScriptblockDefinition)
    }

    [Object] Collect() {
        if ($this.Parameters) {
            $result = $this.Collect($this.Parameters)
        }
        else {
            $result = $this.ScriptBlock.Invoke()[0]
        }

        return $result
    }

    [Object] Collect([System.Collections.IDictionary] $Parameters) {
        if ($this.Module) {
            Import-Module -FullyQualifiedName $this.Module
        }

        return $this.ScriptBlock.Invoke($Parameters)[0]
    }

    [Object] Collect([System.Collections.IEnumerable] $Parameter) {
        if ($this.Module) {
            Import-Module -FullyQualifiedName $this.Module
        }
        
        return $this.ScriptBlock.Invoke($Parameter)[0]
    }
}