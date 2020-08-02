

Function Get-SystemInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        
        [string]$ErrorLog = "$home\retry.txt"
    )
    
    BEGIN{
        Write-Output "ErrorLog: $ErrorLog"
    }

    PROCESS{
        ForEach ($computer in $ComputerName) {
            $os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $computer
            $comp = Get-WmiObject -class Win32_ComputerSystem -ComputerName $computer
            $bios = Get-WmiObject -class Win32_BIOS -ComputerName $computer            
            #Write-Output "ComputerName:  $computer"

            $props = @{ 'ComputerName'=$computer;
                        'OSVersion'=$os.version;
                        'SPVersion'=$os.servicepackmajorversion;
                        'BIOSSerial'=$bios.serialnumber;
                        'Manufacturer'=$comp.manufacturer;
                        'Model'=$comp.model        
            }
            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj
        }
    }
    
    END{}
}

Get-SystemInfo -ErrorLog x.txt -ComputerName localhost,localhost