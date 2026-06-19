Add-Type -AssemblyName System.Windows.Forms

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$converter = Join-Path $scriptDir 'html-to-png.ps1'

if (-not (Test-Path -LiteralPath $converter)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Converter script was not found:`n$converter",
        'HTML to PNG',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

$openDialog = New-Object System.Windows.Forms.OpenFileDialog
$openDialog.Title = 'Choose an HTML file'
$openDialog.Filter = 'HTML Files (*.html;*.htm)|*.html;*.htm|All Files (*.*)|*.*'
$openDialog.Multiselect = $false

if ($openDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    exit 0
}

$inputHtml = $openDialog.FileName
$defaultName = [System.IO.Path]::GetFileNameWithoutExtension($inputHtml) + '-fullpage.png'

$saveDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveDialog.Title = 'Choose where to save PNG'
$saveDialog.Filter = 'PNG Image (*.png)|*.png'
$saveDialog.FileName = $defaultName
$saveDialog.InitialDirectory = Split-Path -Parent $inputHtml
$saveDialog.OverwritePrompt = $true

if ($saveDialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    exit 0
}

$outputImage = $saveDialog.FileName

try {
    & $converter -InputHtml $inputHtml -OutputImage $outputImage

    [System.Windows.Forms.MessageBox]::Show(
        "Done.`n$outputImage",
        'HTML to PNG',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}
catch {
    [System.Windows.Forms.MessageBox]::Show(
        "Failed:`n$($_.Exception.Message)",
        'HTML to PNG',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}
