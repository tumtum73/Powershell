

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

	#Open Command Prompt as Z2 user
#Write-Host -ForegroundColor Yellow "INFO: Open Admin command prompt for Z2 credentials";
	#Commented out on 1/27/16 because Z2 password expired, need to submit 3912 to reinstate...
#	$erroractionpreference = "SilentlyContinue"
#	$strQuit = $Null
#	do {
#	    runas /user:$z2user "cmd /k color b && title %username%"
#     #$?;
#     if ($LASTEXITCODE -ne 0) {
#		 	$strQuit = Read-Host "Do you want to try again?"
#		 		if ($strQuit -ne $Null -Or $strQuit -ne "N") {
#		 			Write-Host -ForegroundColor Yellow "INFO: Stopping attempt to login with Z2 credentials";
#		 		}
#		 }	 	
#	}
#	until ($strQuit -ne $Null -Or $strQuit -ne "N")
	

#Open Command Prompt as ZZ user
#Write-Host -ForegroundColor Yellow "INFO:  Open Command Prompt as ZZ user"
#	do {
#		$Smartcard = Read-Host -Prompt 'Do you want to Starting Command Prompt with Smartcard'
#		Switch ($Smartcard) { 
#		Y {Write-Host -ForegroundColor Yellow "INFO:  Starting Command Prompt with Smartcard"; runas /smartcard "cmd /k color c && title $zzuser"} 
#		N {Write-Host -ForegroundColor Yellow "INFO:  Skipping Command Prompt"} 
#		Default {Write-Host "Unkown Value, try again."; $Smartcard = $null} 
#		}
#	}
#	while ($Smartcard -eq $null)
 

#Testing a Morning Report Script
#Get-Content  c:\scripts\mr\computers.txt | c:\scripts\mr\mr.ps1 -HTML | Out-File c:\scripts\mr\mr2.html;
#$ie.Navigate2("c:\scripts\mr\mr2.html", $navOpenInBackgroundTab);

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
	Start-Process -FilePath $Prog -ArgumentList "file:///C:/Correia/links.html", "https://mynns/teams/T54/IECS/SitePages/Home.aspx", "https://sm/", "https://portal.azure.com", "https://portal.azure.us", "http://tfs/InformationTechnology/T54-Cloud%20Admin/_backlogs?level=Backlog%20items&showParents=false&_a=backlog", "https://dev.azure.com/NIMACVS01", "https://hii-nns.percipio.com/", "https://tools.bluesteel.cloud/jira/secure/RapidBoard.jspa?rapidView=11&projectKey=UHPC&view=planning.nodetail&selectedIssue=UHPC-11","https://newsblur.com/", "https://www.gartner.com/library", "http://docs.cloud.hii-nns.com"
	Write-Host -ForegroundColor Yellow "INFO:  Google Chrome started."
}
else {
	Write-Host -ForegroundColor Yellow "INFO:  Google Chrome already started."
}
$Running = $null

#Starting Microsoft Edge (Legacy)
#Write-Host -ForegroundColor Yellow "INFO:  Starting Microsoft Edge";
#start microsoft-edge:https://myapps.microsoft.com/cloud.hii-nns.com
#start microsoft-edge:https://account.activedirectory.windowsazure.us

#Starting Microsoft Edge (Chromium)
$edge = get-process -Name "msedge" -ErrorAction SilentlyContinue
if ($edge -eq $null) {
	 start msedge "https://myapps.microsoft.com/cloud.hii-nns.com", "https://account.activedirectory.windowsazure.us", "https://dev.azure.com/NIMACVS01/NIMACT54OPS/_queries"
} 
else {
	Write-Output "Edge already running"
}

#Write-Host -ForegroundColor Yellow "INFO: Comparing TFS Groups for Sharepoint CAL licensing";
#c:\scripts\Compare-TFSGroups.ps1
	
#Write-Host -ForegroundColor Yellow "INFO: Starting Job to monitor AppAdmin Web Service";
#Start-Job -FilePath c:\scripts\Get-IISHealthCheck.ps1

#Validate Visual Studio (formerly MSDN) subscriptions
# do {
# 	$Validate = Read-Host -Prompt 'Do you want to execute script to Validate Visual Studio Subscriptions'
# 	Switch ($Validate) 
#      { 
#        Y {Write-Host -ForegroundColor Yellow "INFO:  Starting Script to Validate Visual Studio Subscriptions";c:\correia\work\validate-vs.ps1} 
#        N {Write-Host -ForegroundColor Yellow "INFO:  Skipping Visual Studio Validation"} 
#        Default {Write-Host "Unkown Value, try again."; $Validate = $null} 
#      } 
# }
# while ($Validate -eq $null)


	
	
#***Functions***

function Get-SecurePassword($UserName) {
	$cred = Get-Credential $UserName
	$plainTextPassword = $cred.GetNetworkCredential().Password;
	$domain = $cred.GetNetworkCredential().Domain;
	$user =  $cred.GetNetworkCredential().UserName;

	while (!(test-adcredentials $user $plainTextPassword))  {
		Write-Host -ForegroundColor Red "Password incorrect for $UserName.  Please try again." 
		$cred = Get-Credential $UserName
		$plainTextPassword = $cred.GetNetworkCredential().Password;
		$domain = $cred.GetNetworkCredential().Domain;
		$user =  $cred.GetNetworkCredential().UserName;
	}

	Return (ConvertTo-SecureString  $plainTextPassword  -AsPlainText -force);
}
