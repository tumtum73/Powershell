# Powershell
Collection of Powershell scripts for Stephen Correia

### chocolatey-remove.ps1
This script will uninstall chocolatey, I rarely do this.

### chocolatey-setup.ps1
This script is used to install chocolatey and specific software I use allot.

### guess.ps1
This script is a fork from Mike Robbins that gets a random number and gives you 7 tries to guess the number.

### Create-VM.ps1
This script will typically create a resource group, storage account, and unique VM.  Although you can pass existing resource group name, or storage account name.  It will also attmept to determine your client public IP and add that to the Network Security Group as an IP white list.

### Get-SystemInfo.ps1
This script is what I came up with while working through the Learn Powershell Toolmaking in a Month
of Lunches book.

### profile.ps1
This script is what I put in my profile to customize it a bit to me.  It adds a comment stating how many days until Christmas and My Birthday.

### Setup-Server.ps1
This script is used to configure serers the way I like them.  For example:
- Set Timezone to EST
- Set Clock to 24 hoour time format
- Set Active Hours
- Hide Server Manager At Logon
- Configure Explorer interface
    - Enabling showing hidden files"
    - Disabling hiding extensions for known files
    - Disabling showing hidden operation system files
    - Enabling never group taskbar items option"
- Disable Internet Explorer
- Install chocolatey (my favorite management software)
    - Install Notepad++
    - Install 7zip
    - Install sysinternals tools
    - Install Visual Studio Code
    - Install wireshark
    - Install Edge (Chromium)

### startup.ps1
This script is used ot stratup my windows environmenent in the morning.  For example:
- Starts Outlook witrh the appropriate settings depending on if I have a two moinotr setup or not.
- Starts Jabber
- Sets up common file share
- Shutdown SnagIt
- Check for passwrod expiration and email notification
- Start Google Chrome with commonly used tabs
- Start Microsoft Edge with commonly used tabs

### template.ps1
Powershell template for starting scripts from scratch.
