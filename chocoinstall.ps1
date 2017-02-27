<#

Usage:
powershell "Set-ExecutionPolicy Unrestricted; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/TaylorMonacelli/chocoinstall/master/chocoinstall.ps1'))"

#>

#FIXME: sign this script so I don't have to run urestricted.

function Get-DotNetVersions {
    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
    Get-ItemProperty -name Version,Release -EA 0 |
    Where { $_.PSChildName -match '^(?!S)\p{L}'} |
    Select PSChildName, Version, Release, @{
        name="Product"
        expression={
            switch -regex ($_.Release) {
                "378389" {
                    [Version]"4.5" 
                }
                "378675|378758" {
                    [Version]"4.5.1" 
                }
                "379893" {
                    [Version]"4.5.2" 
                }
                "393295|393297" {
                    [Version]"4.6" 
                }
                "394254|394271" {
                    [Version]"4.6.1" 
                }
                "394802|394806" {
                    [Version]"4.6.2" 
                } {$_ -gt 394806} {
                    [Version]"Undocumented 4.6.2 or higher, please update script" 
                }
            }
        }
    }
}

function Test-NeedDotNetUpdate {

    $is462OrGreater = $false
    try {
        $installed = (Get-DotNetVersions).Version |
        Sort-Object -Descending | Select-Object -first 1
    } Catch [System.Management.Automation.RuntimeException] {
        $message = "TRAPPED: {0}: '{1}'" -f ($_.Exception.GetType().FullName),($_.Exception.Message)
        if($message -like '*Undocumented 4.6.2 or higher*'){
            $is462OrGreater = $true
        }
    }

    if($is462OrGreater) {
        return $false
    }

    if([version]'4.6.2' -gt [version]$installed) {
        return $true
    }
}

$minSpaceMB=125
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size,FreeSpace
$freeSpaceMB = [Math]::Round($disk.Freespace / 1MB)
if($freeSpaceMB -lt $minSpaceMB) {
    Write-Host "I need at least $minSpaceMB MB, but only $freeSpaceMB is available, quitting"
    Exit 1
}

# Check and Install .Net 4.6.2 if necessary
if(Test-NeedDotNetUpdate) {

    $url="https://download.microsoft.com/download/F/9/4/F942F07D-F26F-4F30-B4E3-EBD54FABA377/NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
    $outfile="NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
    if(!(test-path $outfile)){
        (new-object System.Net.WebClient).DownloadFile($url, $outfile)
    }
    cmd /c start /wait ./NDP462-KB3151800-x86-x64-AllOS-ENU.exe /q /norestart
    if($?) {
        Remove-Item NDP462-KB3151800-x86-x64-AllOS-ENU.exe >$null
    }
}

# Windows Management Framework (WMF) 5.0
$url="https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win7-KB3134760-x86.msu"
$outfile="${env:TEMP}\Win7-KB3134760-x86.msu"
if(!(test-path $outfile)){
    (new-object System.Net.WebClient).DownloadFile($url, $outfile)
}

mkdir -Force "${env:TEMP}\KB3134760" >$null
expand -f:* $outfile "${env:TEMP}\KB3134760"
dism.exe /norestart /Quiet /Online /Add-Package /PackagePath:"${env:TEMP}\KB3134760\Windows6.1-KB3134760-x86.cab"
if($?) {
    Remove-Item -Recurse "${env:TEMP}\KB3134760" >$null
}


# Finally install chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$env:PATH += ";${env:SYSTEMDRIVE}\ProgramData\chocolatey"
choco install powershell --yes
