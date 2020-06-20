class RefreshSchedule {

    $Definition = 'NA'

    RefreshSchedule() {

    }

    RefreshSchedule ([System.Collections.IDictionary]$Definition) {

        $this.Definition = $Definition | ConvertTo-Json -Compress
    }
}