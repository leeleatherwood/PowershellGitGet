function Install-ModuleFromGit
{
	Param(
		[Parameter(Mandatory=$True)]
		[string]$GitURL,

		[Parameter(Mandatory=$False)]
		[string]$Branch='master',

		[Parameter(Mandatory=$False)]
		[string]$Username,

		[Parameter(Mandatory=$False)]
		[string]$Password,

		[Parameter(Mandatory=$False)]
		[switch]$Force
	)

	$archiveURL = $GitURL.Replace('.git',"/archive/$Branch.zip")
	$outfilePath = $env:TEMP + '\' + $GitURL.Split('/')[-1] + ".zip"
	$outfolderPath = $outfilePath.Replace('.zip','')

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	Write-Output "Downloading git archive $archiveURL"

	if ($Username -and $Password)
	{
		$credString = "{0}:{1}" -f $Username,$Password
		$creds = [Convert]::ToBase64String([System.Text.Encoding]::Ascii.GetBytes($credString))
		Invoke-WebRequest -Uri $archiveURL -OutFile $outfilePath -Headers @{"Authorization"="Basic $creds"}
	}
	else
	{
		Invoke-WebRequest -Uri $archiveURL -OutFile $outfilePath
	}

	Remove-Item $outfolderPath -Recurse -Force -ErrorAction 'SilentlyContinue'
	Expand-Archive -LiteralPath $outfilePath -DestinationPath $outfolderPath
	Remove-Item $outfilePath -Force -ErrorAction 'SilentlyContinue'

	$psdFile = Get-ChildItem –Path $outfolderPath -Include "*.psd1" -Recurse -ErrorAction 'SilentlyContinue'

	if ($psdFile -eq $null)
	{
		Write-Error "Invalid Powershell Module"
		return
	}

	# Import-Module -Name $psdFile.FullName -Force -Verbose

	$psdData = Import-PowerShellDataFile -LiteralPath $psdFile.FullName

	Write-Output "Installing Powershell Module $($psdFile.BaseName) $($psdData.ModuleVersion)"

	$moduleDestination = "C:\Program Files\WindowsPowerShell\Modules\" + $psdFile.BaseName + "\" + $psdData.ModuleVersion

	Remove-Item $moduleDestination -Recurse -Force -ErrorAction 'SilentlyContinue'
	New-Item -Path $moduleDestination -ItemType 'Directory' -Force | out-null
	Copy-Item -Path "$($psdFile.DirectoryName)\*" -Destination $moduleDestination -Recurse -Force

	Write-Output "Installation Complete"

	return $psdData
}