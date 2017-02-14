<#

Usage:
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/TaylorMonacelli/chocoinstall/master/chocoinstall.ps1'))

#>

#FIXME: this reboots.  Not sure which step is doing it.

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
cmd /c start /wait ./NDP462-KB3151800-x86-x64-AllOS-ENU.exe /q /norestart

mkdir KB3134760
expand -f:* $pwd\Win7-KB3134760-x86.msu KB3134760
dism.exe /norestart /Online /Add-Package /PackagePath:$pwd\KB3134760\Windows6.1-KB3134760-x86.cab

# Finally install chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$env:PATH += ";${env:SYSTEMDRIVE}ProgramData\chocolatey"
choco install powershell --yes
