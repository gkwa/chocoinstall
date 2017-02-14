if (test-path Alias:\wget) {
	Remove-Item Alias:\wget
}

# .Net 4.6.2:
$url="https://download.microsoft.com/download/F/9/4/F942F07D-F26F-4F30-B4E3-EBD54FABA377/NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
$outfile="NDP462-KB3151800-x86-x64-AllOS-ENU.exe"
(new-object System.Net.WebClient).DownloadFile($url, $outfile)
cmd /c start /wait ./NDP462-KB3151800-x86-x64-AllOS-ENU.exe /q

# Windows Management Framework (WMF) 5.0
$url="https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win7-KB3134760-x86.msu"
$outfile="Win7-KB3134760-x86.msu"
(new-object System.Net.WebClient).DownloadFile($url, $outfile)
cmd /c start /wait ./NDP462-KB3151800-x86-x64-AllOS-ENU.exe /q

mkdir KB3134760
expand -f:* $pwd\Win7-KB3134760-x86.msu KB3134760
dism.exe /norestart /Online /Add-Package /PackagePath:$pwd\KB3134760\Windows6.1-KB3134760-x86.cab
