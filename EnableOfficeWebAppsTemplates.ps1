$site = Get-SPSite http://serverurl

$site | Get-SPWeb -limit all | ForEach-Object {Enable-SPFeature -Identity "Office Web Apps Document Templates" -Url $_.Url}

$site.Dispose()