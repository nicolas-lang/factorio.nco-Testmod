Remove-Variable * -ErrorAction SilentlyContinue;
Remove-Module *; $error.Clear();
Clear-Host; $ErrorActionPreference = "Stop"
[string] $baseDirectory = (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent).TrimEnd("/").TrimEnd("\")

#-----------------------------------------------------------------------
Add-Type -As System.IO.Compression.FileSystem
function Create-ModArchive {
	param(
		[string]$DestinationPath
		, [string]$SubFolder
		, [string]$SourceFolder
	)
	$sourcePath = (Get-Item $SourceFolder).FullName
	$archive = [System.IO.Compression.ZipFile]::Open($DestinationPath, "Create")
	[System.IO.Compression.CompressionLevel]$compression = "Optimal"

	Get-ChildItem -Recurse $SourceFolder | where { (! $_.PSIsContainer) -and ($_.Name -NotLike "*.ps1") -and ($_.Name -NotLike ".git*") -and ($_.BaseName -ne "") } | % {
		$relPath = $($SubFolder + ($_.FullName -replace $("^" + [System.Text.RegularExpressions.Regex]::Escape($sourcePath)), ''))
		$relPath = $($relPath -replace ([System.Text.RegularExpressions.Regex]::Escape("\")), "/")
		Write-verbose $relPath
		$null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $_.FullName, $relPath, $compression)
	}
	$archive.Dispose()
}
#-----------------------------------------------------------------------
function Deploy-Mod {
	param(
		[string]$modFolder
	)
	$modFolder = $modFolder.TrimEnd("\")
	If (!(test-path $modFolder)) {
		Write-Host "Source Folder $modFolder not found"
		return
	}
	$modInfo = (Get-Content -Path "$modFolder\info.json" | ConvertFrom-Json)
	#-----------------------------------------------------------------------
	$modFullName = $($modInfo.name + "_" + $modInfo.version)
	$modArchivePath = $($env:APPDATA + "\Factorio\mods\" + $modFullName + ".zip")
	If (test-path $modArchivePath) {
		Remove-Item -path $modArchivePath
	}
	#-----------------------------------------------------------------------
	Create-ModArchive -SourceFolder "$modFolder" -DestinationPath $modArchivePath -SubFolder $modInfo.name
}
#-----------------------------------------------------------------------
function Get-SteamFolder () {
	$steamFolder = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam' -Name InstallPath).InstallPath
	if ((Test-Path $steamFolder) -eq $false) {
		return (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam' -Name InstallPath).InstallPath
	}
	return $steamFolder
}
#=======================================================================
Deploy-Mod -modFolder $baseDirectory
#-----------------------------------------------------------------------
$steamFolder = Get-SteamFolder
&"$steamFolder\steam.exe" -applaunch 427520
