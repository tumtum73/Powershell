$DaysToXmas = (New-TimeSpan -Start (Get-Date) -End "12/25/$((Get-Date).Year)").Days
$DaysToBday = (New-TimeSpan -Start (Get-Date) -End "08/22/$((Get-Date).Year)").Days

Write-Host -Foreground Yellow "$DaysToXmas days until Christmas!"
Write-Host -Foreground Yellow "$DaysToBday days until My Birthday!"
