#Check for Admin
#Reference:  https://blogs.technet.microsoft.com/heyscriptingguy/2011/05/11/check-for-admin-credentials-in-a-powershell-script/
Write-Output  "INFO: Checking to ensure Powershell was started with Admin rights"
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
} Else {
    Write-Output  "INFO: Admin rights confirmed"
}

#Reference:  https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-operatingsystem
#Reference:  https://www.prajwaldesai.com/windows-operating-system-version-numbers/
$os = (Get-WMIObject win32_operatingsystem).Caption

#Set Timezone to EST
Write-Output  "INFO: Setting Timezone to US EST"
set-timezone -Name "US Eastern Standard Time"

#Set Time to 24 hr time
#Reference: https://gallery.technet.microsoft.com/scriptcenter/How-to-change-the-System-82479048
Write-Output  "INFO: Setting Time to 24 hr time - this may require you to logoff and back on to take effect."
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value "HH:mm tt"


if ($os -eq "Microsoft Windows Server 2012 R2 Datacenter") {
    Write-Output "INFO:  Skipping Active Hours for Server 2012 - N/A"
} Else {
    #Set Active Hours to 08:00 - 17:00
    #Reference:  http://itknowledgeexchange.techtarget.com/powershell/set-active-hours/
    Write-Output  "INFO: Setting Active Hours for Server to 08:00 - 17:00"
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name ActiveHoursStart -Value 8 -PassThru
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name ActiveHoursEnd -Value 17 -PassThru
}

#Hide Server Manager At Logon
#Reference:  https://blogs.technet.microsoft.com/rmilne/2014/05/30/how-to-hide-server-manager-at-logon/
Write-Output  "INFO: Hiding Server Manager at Logon"
New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "0x1" –Force

#Configure Explorer interface
#Reference:  https://knowledge.zomers.eu/PowerShell/Pages/How-to-configure-Windows-Explorer-settings-via-PowerShell.aspx
$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Write-Output "INFO:  Enabling showing hidden files"
Set-ItemProperty $key Hidden 1
Write-Output "INFO:  Disabling hiding extensions for known files"
Set-ItemProperty $key HideFileExt 0
Write-Output "INFO:  Disabling showing hidden operation system files"
Set-ItemProperty $key ShowSuperHidden 0
Write-Output "INFO:  Enabling never group taskbar items option"
Set-ItemProperty $key TaskbarGlomLevel 2


#Install Chocolatey
#Reference:  
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Output  "INFO: Installing Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install notepadplusplus.install -y
choco install 7zip.install -y
choco install sysinternals -y
choco install visualstudiocode -y
choco install wireshark -y

#Import Powershell PSreadLine Module to enable command history
#Reference:  http://woshub.com/powershell-commands-history/
Install-Module PSReadLine
