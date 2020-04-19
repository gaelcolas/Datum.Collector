using namespace System.Collections
class ClearTextCredential {
    
    [pscredential] static GetCredential($Definition) {
        return [pscredential]::new($Definition.Username, ($Definition.Password | ConvertTo-SecureString -AsPlainText -Force))
    }
}
