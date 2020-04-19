using namespace System.Collections.Specialized
# using namespace YamlDotNet.Serialization

Class DatumCollectorMap : OrderedDictionary {

    DatumCollectorMap (
        [OrderedDictionary]$CollectorMapDefinition
    )
    {
        # From the current DatumCollector Path
        $CollectorMapDefinition.Keys.ForEach{
            # Dispatch the content of that key, using [DatumCollectorMap] if ApiVersion, Kind, Specs not specified
            Write-Debug "Adding Key $_"
            if (!$CollectorMapDefinition.($_).Contains('Name')) {
                $CollectorMapDefinition.($_).Add('Name', $_)
            }
            
            $this.add($_,[ApiDispatcher]::DispatchSpec('DatumCollector',$CollectorMapDefinition.($_)))
            # $this.add($_,$CollectorMapDefinition[$_])
        }
        # foreach key
        # Create a new collector instance
        # add it to a sub property
    }
    # in constructor $this.SetReadOnlyProperty('prop',{$this.psobject.BaseObject.get_prop()})

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