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
        if (!$Definition.Contains('kind')) {
            Write-Debug "Dispatching specs as $DefaultType."
            return [ApiDispatcher]::DispatchSpec(
                [ordered]@{
                    kind = $DefaultType
                    spec = $Definition
                }
            )
        }
        else {
            Write-Debug "Specs defines kind, dispatching."
            return [ApiDispatcher]::DispatchSpec($Definition)
        }
    }

    static [Object] DispatchSpec([IDictionary] $Definition) {
        $moduleString = ''
        $returnCode = ''

        if ($Definition.Kind -match '::') {
            $moduleName, $className = $Definition.Kind.Split('::', 2)
            if ($className -match '::') {
                $className, $StaticMethod = $className.Split('::', 2)
                $StaticMethod.Trim('()')
                Write-Debug -Message "Calling static method '$StaticMethod' from $className."
                $returnCode = "return [$className]::$StaticMethod(`$args[0])"
            }
            else {
                $returnCode = "return [$className]::new(`$args[0])"
            }
            Write-Debug "Module is '$moduleName', Class is '$className'."
            $moduleString = "using module $moduleName"
        }
        elseif ($Definition.Kind -match '\-') {
            if ($Definition.Kind -match '\\') {
                $moduleName, $functionName = $Definition.kind.Split('\\', 2)
                $moduleString = "Import-Module $moduleName"
            }
            else {
                $functionName = $Definition.Kind
            }
            Write-Debug -Message "Calling funcion $functionName"
            $returnCode = "`$params = `$Args[0]`r`n ,($functionName @params)"
        }
        else {
            $className = $Definition.Kind
            $returnCode = "return [$className]::new(`$args[0])"
            Write-Debug "Class is [$className]."
        }

        $specObject = $Definition.Spec
        
        $script = @"
$moduleString
$returnCode
"@
        Write-Debug "ScriptBlock = `r`n$script`r`n"
        return [scriptblock]::Create($script).Invoke($specObject)[0]
    }
}

