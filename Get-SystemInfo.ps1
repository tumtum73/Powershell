

Function Get-SystemInfo {
  
<#
.SYNOPSIS
My implementation of the Get-SystemInfo script worked out in the "Learn Powershell 
Toolmaking in a Month of Lunches" book.

.DESCRIPTION
My implementation of the Get-SystemInfo script worked out in the "Learn Powershell 
Toolmaking in a Month of Lunches" book.

.PARAMETER ComputerName
One or more computer  names or IP addresses, up to a maximum of 10.

.PARAMETER LogErrors
Specify this switch to create a text log file of computers that could not be queried.

.PARAMETER ErrorLog
When used with -LogErrors , specifies the file path and name to which failed computer 
names will be written.  Defaults to $HOME/retry.txt

.EXAMPLE
 Get-Content  names.txt | Get-SystemInfo

.EXAMPLE
 Get-SystemInfo -ComputerName SERVER1, SERVER2

.NOTES
 	Script: 	Get-SystemInfo.ps1
	Version: 	1.0
	Author: 	Stephen Correia
	Date: 		08/02/2020
	Keywords:	
	Comments:	
	References:
    "Learn Powershell Toolmaking in a Month of Lunches"
#>
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true,
                    ValueFromPipeline=$true,
                    HelpMessage="Computer name or IP Address"
        )]
        [ValidateCount(1,10)]
        [Alias('hostname')]
        [string[]]$ComputerName,

        [string]$ErrorLog = "$home\retry.txt",

        [switch]$LogErrors
    )
    
    BEGIN{
        Write-Verbose "ErrorLog will be $ErrorLog"
    }

    PROCESS{
        Write-Verbose "Beginning PROCESS block"
        ForEach ($computer in $ComputerName) {
            Write-Verbose "Querying $computer"
            Try {
                $everything_ok= $true
                $os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $computer -erroraction Stop
            } Catch {
                $everything_ok = $false
                Write-Warning "$computer failed"
                if ($LogErrors) {
                    $computer | Out-File $ErrorLog -Append
                    Write-Warning "Logged to $ErrorLog"
                }
            }
            
            if ($everything_ok) {
                $comp = Get-WmiObject -class Win32_ComputerSystem -ComputerName $computer
                $bios = Get-WmiObject -class Win32_BIOS -ComputerName $computer                    

                $props = @{ 'ComputerName'  = $computer;
                            'OSVersion'     = $os.version;
                            'SPVersion'     = $os.servicepackmajorversion;
                            'BIOSSerial'    = $bios.serialnumber;
                            'Manufacturer'  = $comp.manufacturer;
                            'Model'         = $comp.model        
                }
                Write-Verbose "WMI queries complete"
                $obj = New-Object -TypeName PSObject -Property $props
                $obj.PSObject.TypeNames.Insert(0,'MOL.SystemInfo')
                Write-Output $obj
            }
        }
    }
    
    END{}
}

Get-SystemInfo -ComputerName localhost