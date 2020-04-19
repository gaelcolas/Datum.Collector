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
    
    static [Object] DispatchSpec([string] $DefaultType, [IDictionary] $Definition) {
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
        $Action = ''

        if ($Definition.Kind -match '\\') {

            $moduleName, $Action = $Definition.Kind.Split('\', 2)
            Write-Debug -Message "Module is '$moduleName'"
            if ($Action -match '\-') {
                $moduleString = "Import-Module $moduleName"
            }
            else {
                $moduleString = "using module $moduleName"
            }
        }
        else {
            $Action = $Definition.Kind
        }

        if ($Action -match '\-') {
            # Function
            $functionName = $Action
            Write-Debug -Message "Calling funcion $functionName"
            $returnCode = "`$params = `$Args[0]`r`n ,($functionName @params)"
        }
        elseif ($Action -match '::') {
            # Static Method
            $className, $StaticMethod = $Action.Split('::', 2)
            $StaticMethod = $StaticMethod.Trim('\(\)')
            Write-Debug -Message "Calling static method '[$className]::$StaticMethod(`$spec)'"
            $returnCode = "return [$className]::$StaticMethod(`$args[0])"
        }
        else {
            # Class::New()
            $className = $Action
            Write-Debug -Message "Creating new [$className]"
            $returnCode = "return [$className]::new(`$args[0])"
        }

        $specObject = $Definition.spec
        $script = "$moduleString`r`n$returnCode"
        Write-Debug "ScriptBlock = {`r`n$script`r`n}"
        return [scriptblock]::Create($script).Invoke($specObject)[0]
    }
}

