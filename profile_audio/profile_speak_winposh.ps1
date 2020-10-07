Add-Type -AssemblyName System.Speech
[System.Speech.Synthesis.SpeechSynthesizer] | Out-Null
$ATAVoiceEngine = New-Object System.Speech.Synthesis.SpeechSynthesizer
$ATAVoiceEngine.SelectVoice("Microsoft Zira Desktop")

$quotes = @("Do the right thing", "Learn something new everyday", "Get shit done", "BINGO!!!", "Would you like to play a game?    Thermonuclear War")

$text = $quotes | Get-Random

$ATAVoiceEngine.Speak("The current time is $((Get-Date).ToShortTimeString())")

Write-Output $text
$ATAVoiceEngine.Speak($text)
