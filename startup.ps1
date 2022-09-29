

#***Modules***
Import-Module ActiveDirectory

#***Constants***
	#-Outlook Folders
		$olFolderDeletedItems = 3;
		$olFolderOutbox = 4;
		$olFolderSentMail = 5;
		$olFolderInbox = 6;
		$olFolderCalendar = 9;
		$olFolderContacts = 10;
		$olFolderJournal = 11;
		$olFolderNotes = 12;
		$olFolderTasks = 13;
		$olFolderDrafts = 16;
	#-Outlook Windows Display
		$olFolderDisplayNormal = 0;
		$olFolderDisplayFolderOnly = 1;
		$olFolderDisplayNoNavigation = 2;
	#-Outlook Window State
		$olMaximized = 0;		#The window is maximized.
		$olMinimized = 1;		#The window is minimized.
		$olNormalWindow = 2;	# The window is in the normal state (not minimized or maximized).

	#-Service Account Lookup
		$smtpServer="[mailserver]"
		$expireindays = 21
		$from = "Scripter <scripter@hii-nns.com>"
		$emailaddress = "Stephen Correia <s.correia@hii-nns.com>"
		

#***Main_Script***

	#Initialize Windows Forms
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

	#Dock Info for laptops
		$DockInfo = Get-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\IDConfigDB\CurrentDockInfo"
		$Docked = $DockInfo.DockingState

	#Get-WmiObject win32_desktopmonitor
	#http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/03/use-powershell-to-discover-multi-monitor-information.aspx?utm_source=twitterfeed&utm_medium=twitter
		#$ScreenWidth = Get-WmiObject win32_desktopmonitor | Select -expand ScreenWidth
		
	#Get-WmiObject WmiMonitorBasicDisplayParams
	#http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/03/use-powershell-to-discover-multi-monitor-information.aspx?utm_source=twitterfeed&utm_medium=twitter	


	#Reference: http://stackoverflow.com/questions/7967699/get-screen-resolution-using-wmi-powershell-in-windows-7
	#Add-Type -AssemblyName System.Windows.Forms
	$Displays = [System.Windows.Forms.Screen]::AllScreens


#Starting Outlook
Write-Host -ForegroundColor Yellow "INFO:  Starting Outlook..."
$Running = Get-Process Outlook -ErrorAction SilentlyContinue
if($Running -eq $null){
		$Outlook = New-Object -comObject Outlook.Application;
		Start-Sleep -Seconds 5		
		$Namespace = $Outlook.GetNamespace("MAPI");
		$Namespace.Logon('Outlook');
		$Folder = $Namespace.GetDefaultFolder($olFolderInbox);
		$Explorer = $Folder.GetExplorer($olFolderDisplayNormal);		
		$Explorer.Display();
		$Explorer.WindowState = $olNormalWindow;
		#Moving Outlook
		$Explorer.top = 48;
		$Explorer.left = -$Explorer.width - 5;
		Write-Host -ForegroundColor Yellow "INFO:  Outlook started."
}
else {
	Write-Host -ForegroundColor Yellow "INFO:  Outlook already started."
}

$Running = $null

#Starting Jabber if not running
Write-Host -ForegroundColor Yellow "INFO:  Starting Cisco Jabber..."
$Prog = "C:\Program Files (x86)\Cisco Systems\Cisco Jabber\CiscoJabber.exe"
$Running = Get-Process CiscoJabber -ErrorAction SilentlyContinue
$Start = ([wmiclass]"win32_process").Create($Prog) > $null
if($Running -eq $null){
	$Start
	Write-Host -ForegroundColor Yellow "INFO:  Cisco Jabber started."
}
else {
	Write-Host -ForegroundColor Yellow "INFO:  Cisco Jabber already started."
}

$Running = $null

#Remove Erroneous Login Script mapping
Write-Host -ForegroundColor Yellow "INFO:  Remove Erroneous Login Script mapping for F: drive";
		net use F: /delete

Start-Sleep -Seconds 5

	#Add installs drive mapping
Write-Host -ForegroundColor Yellow "INFO:  Add F: drive mapping to installs drive";
		net use F: \\[server]]\installs 1 > $null

	#Stop SnagIt from runnning
Write-Host -ForegroundColor Yellow "INFO:  Stopping SnagIt processes";
Get-Process snagit* | stop-process -force

#Checking for Password Expiration
Write-Host -ForegroundColor Yellow "INFO:  Checking for Password Expiration"
	$users = get-aduser -filter {(Name -eq $user) -or (Name -eq $z2user)} -properties Name
	#Service Account Lookup
	foreach ($user in $users)
	{
	  $Name = (Get-ADUser $user | foreach { $_.Name})
	  $passwordSetDate = (get-aduser $user -properties * | foreach { $_.PasswordLastSet })
	  $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
	  # Check for Fine Grained Password
	  if (($PasswordPol) -ne $null)
	  {
		$maxPasswordAge = ($PasswordPol).MaxPasswordAge
	  }
	  
	  else
	  {
		$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
	  }
	  
	  
	  $expireson = $passwordsetdate + $maxPasswordAge
	  $today = (get-date)
	  $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
	  $subject="Your password will expire in $daystoExpire days"
	  $body ="
	  Dear $name,
	  <p> Your Password will expire in $daystoexpire days.</p>"
	  
	  if ($daystoexpire -lt $expireindays)
	  {
		Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High
		Write-Host -ForegroundColor Yellow "Mail message sent."		 
	  }  
	   
	}


#Starting Google Chrome
Write-Host -ForegroundColor Yellow "INFO:  Starting Google Chrome";
$Prog = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$Running = Get-Process Chrome -ErrorAction SilentlyContinue
if($Running -eq $null){
	Start-Process -FilePath $Prog -ArgumentList "file:///C:/Correia/links.html", "https://newsblur.com/", "https://www.gartner.com/library"
	Write-Host -ForegroundColor Yellow "INFO:  Google Chrome started."
}
else {
	Write-Host -ForegroundColor Yellow "INFO:  Google Chrome already started."
}
$Running = $null

#Starting Microsoft Edge (Legacy)
#Write-Host -ForegroundColor Yellow "INFO:  Starting Microsoft Edge";
#start microsoft-edge:https://account.activedirectory.windowsazure.us

#Starting Microsoft Edge (Chromium)
$edge = get-process -Name "msedge" -ErrorAction SilentlyContinue
if ($edge -eq $null) {
	 start msedge "https://myapps.microsoft.com/", "https://account.activedirectory.windowsazure.us", "https://dev.azure.com/"
} 
else {
	Write-Output "Edge already running"
}
