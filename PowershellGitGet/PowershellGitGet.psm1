[cmdletbinding()]
param()

Write-Verbose $PSScriptRoot

$functionFolders = @('public', 'private')

foreach ($folder in $functionFolders)
{
    $folderPath = Join-Path -Path "$PSScriptRoot" -ChildPath $folder

    if (Test-Path -Path $folderPath)
    {
        Write-Verbose -Message "Importing from $folder"

        foreach ($function in @(Get-ChildItem -Path $folderPath -Filter '*.ps1' ))
        {
            Write-Verbose -Message "  Importing $($function.BaseName)"

            . $($function.FullName)
        }
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\public\*.ps1").BaseName