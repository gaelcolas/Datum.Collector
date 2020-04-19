using namespace Microsoft.PowerShell.Commands

class DatumCollectorProvider {

    [ModuleSpecification] $Module

    [void] Collect()
    {
        Throw "This class should not be instanciated directly."
    }
}