[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$GitURL = 'https://github.com/leeleatherwood/PowershellGitGet.git'
$archiveURL = $GitURL.Replace('.git',"/archive/master.zip")
$outfilePath = $env:TEMP + '\' + $GitURL.Split('/')[-1] + ".zip"
$outfolderPath = $outfilePath.Replace('.zip','')

Invoke-WebRequest -Uri $archiveURL -OutFile $outfilePath
Remove-Item $outfolderPath -Recurse -Force -ErrorAction 'SilentlyContinue'
Expand-Archive -LiteralPath $outfilePath -DestinationPath $outfolderPath
Remove-Item $outfilePath -Force -ErrorAction 'SilentlyContinue'

$psdFile = Get-ChildItem –Path $outfolderPath -Include "*.psd1" -Recurse -ErrorAction 'SilentlyContinue'
$psdData = Import-PowerShellDataFile -LiteralPath $psdFile.FullName
$psModulePath = ([Environment]::GetEnvironmentVariable("PSModulePath", "Machine")).Split(';')[-1]
$moduleDestination = "$psModulePath\$ModuleName\" + $psdData.ModuleVersion

Remove-Item $moduleDestination -Recurse -Force -ErrorAction 'SilentlyContinue'
New-Item -Path $moduleDestination -ItemType 'Directory' -Force | out-null
Copy-Item -Path "$($psdFile.DirectoryName)\*" -Destination $moduleDestination -Recurse -Force