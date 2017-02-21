<#

Usage:
powershell "Set-ExecutionPolicy Unrestricted; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/TaylorMonacelli/chocoinstall/master/chocoinstall.ps1'))"

TODO: Don't re-install .net if you don't have too, consider: http://www.powershelladmin.com/wiki/List_installed_.NET_versions_on_remote_computers

#>

#FIXME: sign this script so I don't have to run urestricted.

$minSpaceMB=125
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size,FreeSpace
$freeSpaceMB = [Math]::Round($disk.Freespace / 1MB)
if($freeSpaceMB -lt $minSpaceMB)
{
	Write-Host "I need at least $minSpaceMB MB, but only $freeSpaceMB is available, quitting"
	Exit 1
}

# .Net 4.6.2:
$url="https://download.microsoft.com/download/F/9/4/F942F07D-F26F-4F30-B4E3-EBD54FABA377/NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
$outfile="NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
if(!(test-path $outfile)){
	(new-object System.Net.WebClient).DownloadFile($url, $outfile)
}
cmd /c start /wait ./NDP462-KB3151800-x86-x64-AllOS-ENU.exe /q /norestart

# Windows Management Framework (WMF) 5.0
$url="https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win7-KB3134760-x86.msu"
$outfile="Win7-KB3134760-x86.msu"
if(!(test-path $outfile)){
	(new-object System.Net.WebClient).DownloadFile($url, $outfile)
}

mkdir KB3134760
expand -f:* $pwd\Win7-KB3134760-x86.msu KB3134760
dism.exe /norestart /Quiet /Online /Add-Package /PackagePath:$pwd\KB3134760\Windows6.1-KB3134760-x86.cab

# Finally install chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$env:PATH += ";${env:SYSTEMDRIVE}\ProgramData\chocolatey"
choco install powershell --yes
