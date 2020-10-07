#Add-Type -AssemblyName System.Speech
#[System.Speech.Synthesis.SpeechSynthesizer] | Out-Null
#Reference:  https://github.com/PowerShell/PowerShell/issues/12236

$speak = New-Object -ComObject SAPI.SpVoice

$quotes = @("Do the right thing", "Learn something new everyday", "Get shit done", "BINGO!!!", "Would you like to play a game?    Thermonuclear War")
$text = $quotes | Get-Random

Write-Output $text
$speak.Speak($text) | Out-Null

$today = "The current time is $((Get-Date).ToShortTimeString())"
Write-Output $today
$speak.Speak($today) | Out-Null
