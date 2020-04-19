using namespace System.Collections
using namespace System.Collections.Specialized

class ApiDispatcher {
    [string] $ApiVersion
    [string] $Kind
    [string] $Spec
    [OrderedDictionary] $Metadata = [ordered]@{}

    ApiDispatcher() {

    }

    ApiDispatcher([OrderedDictionary] $ApiDefinition) {
        $this.ApiVersion = $ApiDefinition.ApiVersion
        $this.Kind = $ApiDefinition.Kind
        $this.Spec = $ApiDefinition.Spec
        
        $ApiDefinition.keys.Where{$_ -notin @('ApiVersion','Kind','Spec') }.foreach{
            $this.Metadata.Add($_, $ApiDefinition[$_])
        }
    }
    
    static [Object] DispatchSpec([type] $DefaultType, [IDictionary] $Definition) {

        if (!$Definition.keys.Contains('kind')) {
            return [ApiDispatcher]::DispatchSpec(
                [ordered]@{
                    kind = $DefaultType
                    spec = $Definition
                }
            )
        }
        else {
            return [ApiDispatcher]::DispatchSpec($Definition)
        }
    }

    static [Object] DispatchSpec([IDictionary] $Definition) {
        
        if ($Definition.Kind -match '::') {
            $moduleName, $className = $Definition.Kind.Split('::', 2)
            $moduleString = "using module $moduleName"
        }
        else {
            $className = $Definition.Kind
            $moduleString = $null
        }

        $specObject = $Definition.Spec
        
        $script = @"
$moduleString

return [$ClassName]::new(`$args[0])
"@
        
        return [scriptblock]::Create($script).Invoke($specObject)
    }
}

