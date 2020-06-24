[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$gitURL = "https://github.com/leeleatherwood/PowershellGitGet.git"
$psModulePath = "C:\Program Files\WindowsPowerShell\Modules"

$archiveURL = $GitURL.Replace(".git","/archive/master.zip")
$outfilePath = $env:TEMP + "\" + $gitURL.Split("/")[-1] + ".zip"
$outfolderPath = $outfilePath.Replace(".zip","")

Invoke-WebRequest -Uri $archiveURL -OutFile $outfilePath -Headers @{"Cache-Control"="no-cache"}
Remove-Item $outfolderPath -Recurse -Force -ErrorAction "SilentlyContinue"
Expand-Archive -LiteralPath $outfilePath -DestinationPath $outfolderPath

$psdFile = Get-ChildItem –Path $outfolderPath -Include "*.psd1" -Recurse
$psdData = Import-PowerShellDataFile -LiteralPath $psdFile.FullName
$moduleDestination = "$psModulePath\PowershellGitGet\" + $psdData.ModuleVersion

Remove-Item $moduleDestination -Recurse -Force -ErrorAction "SilentlyContinue"
New-Item -Path $moduleDestination -ItemType "Directory" -Force | out-null
Copy-Item -Path "$($psdFile.DirectoryName)\*" -Destination $moduleDestination -Recurse -Force
Import-Module (Get-ChildItem –Path $moduleDestination -Include "*.psd1" -Recurse).FullName -Force -Verbose
Remove-Item $outfolderPath -Recurse -Force -ErrorAction "SilentlyContinue"

if (Get-Module -Name 'PowershellGitGet')
{
	Write-Output "Installation of PowershellGitGet v$($psdData.ModuleVersion) Complete"
}
else
{
	Write-Output "Installation Failed"
}