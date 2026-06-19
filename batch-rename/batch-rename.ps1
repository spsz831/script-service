[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$Match = '*',

    [string]$Prefix,

    [string]$Suffix,

    [string]$Find,

    [string]$Replace
)

$ErrorActionPreference = 'Stop'
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path

$files = Get-ChildItem -LiteralPath $resolvedPath -File -Filter $Match -ErrorAction Stop
foreach ($file in $files) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $extension = $file.Extension
    $newBaseName = $baseName

    if ($Find) {
        $newBaseName = $newBaseName.Replace($Find, $Replace)
    }
    if ($Prefix) {
        $newBaseName = $Prefix + $newBaseName
    }
    if ($Suffix) {
        $newBaseName = $newBaseName + $Suffix
    }

    $newName = $newBaseName + $extension
    if ($newName -ne $file.Name) {
        if ($PSCmdlet.ShouldProcess($file.FullName, "Rename to $newName")) {
            Rename-Item -LiteralPath $file.FullName -NewName $newName
            Write-Host "$($file.Name) -> $newName"
        }
    }
}
