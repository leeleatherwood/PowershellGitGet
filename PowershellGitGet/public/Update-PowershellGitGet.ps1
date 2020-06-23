function Update-PowershellGitGet
{
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/leeleatherwood/PowershellGitGet/master/Install-PowershellGitGet.ps1'))
}