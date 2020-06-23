[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$moduleName = "PowershellGitGet"
$gitURL = "https://github.com/leeleatherwood/PowershellGitGet.git"

$archiveURL = $GitURL.Replace(".git","/archive/master.zip")
$outfilePath = $env:TEMP + "\" + $gitURL.Split("/")[-1] + ".zip"
$outfolderPath = $outfilePath.Replace(".zip","")

Invoke-WebRequest -Uri $archiveURL -OutFile $outfilePath -Headers @{"Cache-Control"="no-cache"}
Remove-Item $outfolderPath -Recurse -Force -ErrorAction "SilentlyContinue"
Expand-Archive -LiteralPath $outfilePath -DestinationPath $outfolderPath

$psdFile = Get-ChildItem –Path $outfolderPath -Include "*.psd1" -Recurse
$psdData = Import-PowerShellDataFile -LiteralPath $psdFile.FullName
$psModulePath = ([Environment]::GetEnvironmentVariable("PSModulePath", "Machine")).Split(";")[-1]
$moduleDestination = "$psModulePath\$moduleName\" + $psdData.ModuleVersion

Remove-Item $moduleDestination -Recurse -Force -ErrorAction "SilentlyContinue"
New-Item -Path $moduleDestination -ItemType "Directory" -Force | out-null
Copy-Item -Path "$($psdFile.DirectoryName)\*" -Destination $moduleDestination -Recurse -Force

$psdFile = Get-ChildItem –Path $moduleDestination -Include "*.psd1" -Recurse
Import-Module $psdFile.FullName -Force -Verbose