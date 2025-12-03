$DaysToXmas = (New-TimeSpan -Start (Get-Date) -End "12/25/$((Get-Date).Year)").Days

if ((Get-Date).Month -gt 8) {($DaysToBday = (New-TimeSpan -Start (Get-Date) -End "08/22/$((Get-Date).Year+1)").Days)}
  else {$DaysToBday = (New-TimeSpan -Start (Get-Date) -End "08/22/$((Get-Date).Year)").Days}

Write-Host -Foreground Yellow "$DaysToXmas days until Christmas!"
Write-Host -Foreground Yellow "$DaysToBday days until My Birthday!"
