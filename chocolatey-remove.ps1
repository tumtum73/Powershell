choco uninstall 7zip.install -y
choco uninstall notepadplusplus -y
choco uninstall firefox -y
choco uninstall putty.install -y
choco uninstall sysinternals -y
choco uninstall gimp -y`
choco uninstall google-chrome-x64 -y
choco uninstall wireshark -y
choco uninstall visualstudiocode -y
choco uninstall awscli -y

Remove-Item -Recurse -Force "$env:ChocolateyInstall"
[System.Text.RegularExpressions.Regex]::Replace( ` 
[Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '',  `
[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString(),  `
[System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', `
[System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | `
%{[System.Environment]::SetEnvironmentVariable('PATH', $_, 'User')}
[System.Text.RegularExpressions.Regex]::Replace( `
[Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', `
[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString(),  `
[System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', `
[System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | `
%{[System.Environment]::SetEnvironmentVariable('PATH', $_, 'Machine')}

Write-Host "If you have made it here without errors, you should be setup and ready to hack on the apps."
Write-Warning "If you see any failures happen, you may want to reboot and continue to let installers catch up. This script is idempotent and will only apply changes that have not yet been applied."
