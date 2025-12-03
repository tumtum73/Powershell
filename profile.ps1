$DaysToXmas = (New-TimeSpan -Start (Get-Date) -End "12/25/$((Get-Date).Year)").Days

# Determine if todays daye is after my birthday or not, to accurately display the days until my birthday.
$myBday = "8/22/"
if ((Get-Date) -gt (Get-Date -Month 8 -Day 22)) {$DaysToBday = (New-TimeSpan -Start (Get-Date) -End "$myBday$((Get-Date).Year+1)").Days} 
  else {$DaysToBday = (New-TimeSpan -Start (Get-Date) -End "$myBday$((Get-Date).Year)").Days}

Write-Host -Foreground Yellow "$DaysToXmas days until Christmas!"
Write-Host -Foreground Yellow "$DaysToBday days until My Birthday!"
