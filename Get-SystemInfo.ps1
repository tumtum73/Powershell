

Function Get-SystemInfo {
    [CmdletBinding()]
    param(
        [string[]]$ComputerName,
        [string]$ErrorLog
    )
    
    BEGIN{}

    PROCESS{
        Write-Output "ComputerName:  $ComputerName"
        Write-Output "ErrorLog: $ErrorLog"

        # $ComputerName
        # $WorkGroup
        # $AdminPassword
        # $Model
        # $Manufacturer
        # $BIOSSerial
        # $OSVersion
        # $SPVersion
    }
    
    END{}
}

Get-SystemInfo -ComputerName one, two, three -ErrorLog x.txt
Get-SystemInfo one x.txt