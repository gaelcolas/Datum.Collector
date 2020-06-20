using namespace System.Collections.Specialized
# using namespace YamlDotNet.Serialization

Class DatumCollectorMap {

    [OrderedDictionary] hidden $__InternalStore = [ordered]@{}

    DatumCollectorMap (
        [OrderedDictionary]$CollectorMapDefinition
    )
    {
        # From the current DatumCollector Path
        $CollectorMapDefinition.Keys.ForEach{
            Write-Debug "Adding Key $_"
            $this.SetMapProperty($_, $CollectorMapDefinition.($_))
        }
    }

    hidden [void] SetMapProperty($Name, $Definition) {
        if ($this.__InternalStore.Contains($Name)) {
            $this.__InternalStore.Remove($Name)
        }
        Write-Debug "Setting Map Propety Name: $Name"
        $this.__InternalStore.add($Name,[ApiDispatcher]::DispatchSpec('DatumCollector',$Definition))
        # Internal store keeps the DatumCollector instance, the Script property calls the GetValue method
        $this.SetReadOnlyProperty($Name, [scriptblock]::Create("`$this.__InternalStore.('$Name').GetValue()"))
    }

    [void] hidden SetReadOnlyProperty($Name, $Getter) 
    {
        $this | Add-Member -Name $Name -MemberType ScriptProperty -Value $Getter -SecondValue { throw "This property is ReadOnly."} -Force
    }

    [string] hidden ToYaml()
    {
        return ($this | ConvertTo-Yaml -Options EmitDefaults)
    }

    [string] hidden ToJson()
    {
        return ($this | ConvertTo-Yaml -Options EmitDefaults,JsonCompatible)
    }

    [string] ToString()
    {
        return $this.ToYaml()
    }

    [OrderedDictionary] hidden ToOrderedDictionary()
    {
        return ($this.ToYaml() | ConvertFrom-Yaml -Ordered)
    }
}