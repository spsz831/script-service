[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$previewRoot = Join-Path $repoRoot 'docs\previews'

New-Item -ItemType Directory -Force -Path $previewRoot | Out-Null

function New-TerminalPreview {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string[]]$Lines,

        [int]$Width = 1400,

        [int]$Height = 820
    )

    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $background = [System.Drawing.Color]::FromArgb(13, 17, 23)
    $panel = [System.Drawing.Color]::FromArgb(22, 27, 34)
    $border = [System.Drawing.Color]::FromArgb(48, 54, 61)
    $text = [System.Drawing.Color]::FromArgb(230, 237, 243)
    $muted = [System.Drawing.Color]::FromArgb(139, 148, 158)
    $green = [System.Drawing.Color]::FromArgb(63, 185, 80)
    $blue = [System.Drawing.Color]::FromArgb(88, 166, 255)
    $orange = [System.Drawing.Color]::FromArgb(210, 153, 34)

    $graphics.Clear($background)

    $panelBrush = New-Object System.Drawing.SolidBrush $panel
    $borderPen = New-Object System.Drawing.Pen $border, 2
    $textBrush = New-Object System.Drawing.SolidBrush $text
    $mutedBrush = New-Object System.Drawing.SolidBrush $muted

    $graphics.FillRectangle($panelBrush, 40, 40, $Width - 80, $Height - 80)
    $graphics.DrawRectangle($borderPen, 40, 40, $Width - 80, $Height - 80)

    $graphics.FillEllipse((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 95, 86))), 70, 68, 18, 18)
    $graphics.FillEllipse((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 189, 46))), 100, 68, 18, 18)
    $graphics.FillEllipse((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(39, 201, 63))), 130, 68, 18, 18)

    $titleFont = New-Object System.Drawing.Font 'Segoe UI', 20, ([System.Drawing.FontStyle]::Bold)
    $codeFont = New-Object System.Drawing.Font 'Consolas', 18
    $metaFont = New-Object System.Drawing.Font 'Segoe UI', 12

    $graphics.DrawString($Title, $titleFont, $textBrush, 170, 58)
    $graphics.DrawString('script-service preview', $metaFont, $mutedBrush, $Width - 270, 64)

    $lineY = 130
    foreach ($line in $Lines) {
        $lineColor = $text
        if ($line.StartsWith('[success]')) {
            $lineColor = $green
        }
        elseif ($line.StartsWith('[info]')) {
            $lineColor = $blue
        }
        elseif ($line.StartsWith('[warn]')) {
            $lineColor = $orange
        }
        elseif ($line.StartsWith('[1/') -or $line.StartsWith('[2/') -or $line.StartsWith('[3/') -or $line.StartsWith('[4/') -or $line.StartsWith('[5/') -or $line.StartsWith('[6/')) {
            $lineColor = [System.Drawing.Color]::FromArgb(121, 192, 255)
        }

        $lineBrush = New-Object System.Drawing.SolidBrush $lineColor
        $graphics.DrawString($line, $codeFont, $lineBrush, 80, $lineY)
        $lineBrush.Dispose()
        $lineY += 38
    }

    $outputDir = Split-Path -Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    }

    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $metaFont.Dispose()
    $codeFont.Dispose()
    $titleFont.Dispose()
    $mutedBrush.Dispose()
    $textBrush.Dispose()
    $borderPen.Dispose()
    $panelBrush.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

function New-HtmlToPngPreview {
    $outputPath = Join-Path $previewRoot 'html-to-png.png'
    $bitmap = New-Object System.Drawing.Bitmap 1440, 900
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $background = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle 0, 0, 1440, 900),
        ([System.Drawing.Color]::FromArgb(255, 248, 239)),
        ([System.Drawing.Color]::FromArgb(243, 247, 255)),
        90
    )

    $graphics.FillRectangle($background, 0, 0, 1440, 900)

    $navy = [System.Drawing.Color]::FromArgb(24, 40, 74)
    $orange = [System.Drawing.Color]::FromArgb(247, 127, 0)
    $muted = [System.Drawing.Color]::FromArgb(92, 103, 125)
    $cardBorder = [System.Drawing.Color]::FromArgb(232, 236, 245)

    $eyebrowBrush = New-Object System.Drawing.SolidBrush $navy

    $eyebrowRect = New-Object System.Drawing.Rectangle 80, 70, 290, 54
    $eyebrowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $radius = 26
    $eyebrowPath.AddArc($eyebrowRect.X, $eyebrowRect.Y, $radius, $radius, 180, 90)
    $eyebrowPath.AddArc($eyebrowRect.Right - $radius, $eyebrowRect.Y, $radius, $radius, 270, 90)
    $eyebrowPath.AddArc($eyebrowRect.Right - $radius, $eyebrowRect.Bottom - $radius, $radius, $radius, 0, 90)
    $eyebrowPath.AddArc($eyebrowRect.X, $eyebrowRect.Bottom - $radius, $radius, $radius, 90, 90)
    $eyebrowPath.CloseFigure()
    $graphics.FillPath($eyebrowBrush, $eyebrowPath)

    $eyebrowFont = New-Object System.Drawing.Font 'Segoe UI', 20, ([System.Drawing.FontStyle]::Bold)
    $headlineFont = New-Object System.Drawing.Font 'Segoe UI', 54, ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Object System.Drawing.Font 'Segoe UI', 22
    $cardLabelFont = New-Object System.Drawing.Font 'Segoe UI', 16
    $cardTitleFont = New-Object System.Drawing.Font 'Segoe UI', 22, ([System.Drawing.FontStyle]::Bold)
    $cardValueFont = New-Object System.Drawing.Font 'Segoe UI', 26, ([System.Drawing.FontStyle]::Bold)
    $tagFont = New-Object System.Drawing.Font 'Segoe UI', 16

    $whiteBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $navyBrush = New-Object System.Drawing.SolidBrush $navy
    $mutedBrush = New-Object System.Drawing.SolidBrush $muted
    $orangeBrush = New-Object System.Drawing.SolidBrush $orange
    $cardPen = New-Object System.Drawing.Pen $cardBorder, 2

    $graphics.DrawString('script-service preview', $eyebrowFont, $whiteBrush, 104, 80)
    $graphics.DrawString("Export local HTML`r`nto a long PNG", $headlineFont, $navyBrush, 80, 160)
    $graphics.DrawString('html-to-png can turn a local single-page HTML file into a clean shareable PNG by using the built-in headless browser screenshot workflow.', $bodyFont, $navyBrush, (New-Object System.Drawing.RectangleF 80, 320, 1100, 90))

    $cardRects = @(
        (New-Object System.Drawing.Rectangle 80, 470, 390, 180),
        (New-Object System.Drawing.Rectangle 525, 470, 390, 180),
        (New-Object System.Drawing.Rectangle 970, 470, 390, 180)
    )
    $cardLabels = @('Input', 'Output', 'Run')
    $cardTitles = @('Local HTML', 'Long PNG', 'Double-click or CLI')
    $cardValues = @('.html / .htm', '-fullpage.png', '.cmd / .ps1')

    for ($i = 0; $i -lt $cardRects.Count; $i++) {
        $cardRect = $cardRects[$i]
        $cardPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $cardRadius = 28
        $cardPath.AddArc($cardRect.X, $cardRect.Y, $cardRadius, $cardRadius, 180, 90)
        $cardPath.AddArc($cardRect.Right - $cardRadius, $cardRect.Y, $cardRadius, $cardRadius, 270, 90)
        $cardPath.AddArc($cardRect.Right - $cardRadius, $cardRect.Bottom - $cardRadius, $cardRadius, $cardRadius, 0, 90)
        $cardPath.AddArc($cardRect.X, $cardRect.Bottom - $cardRadius, $cardRadius, $cardRadius, 90, 90)
        $cardPath.CloseFigure()
        $graphics.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(252, 253, 255))), $cardPath)
        $graphics.DrawPath($cardPen, $cardPath)
        $graphics.DrawString($cardLabels[$i], $cardLabelFont, $mutedBrush, $cardRect.X + 26, $cardRect.Y + 26)
        $graphics.DrawString($cardTitles[$i], $cardTitleFont, $navyBrush, $cardRect.X + 26, $cardRect.Y + 64)
        $graphics.DrawString($cardValues[$i], $cardValueFont, $orangeBrush, $cardRect.X + 26, $cardRect.Y + 112)
        $cardPath.Dispose()
    }

    $tags = @('Windows', 'Edge / Chrome', 'PowerShell', 'Fast export')
    $tagX = 80
    foreach ($tag in $tags) {
        $size = $graphics.MeasureString($tag, $tagFont)
        $tagRect = New-Object System.Drawing.Rectangle ([int]$tagX), 730, ([int]($size.Width + 34)), 50
        $tagPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $tagRadius = 24
        $tagPath.AddArc($tagRect.X, $tagRect.Y, $tagRadius, $tagRadius, 180, 90)
        $tagPath.AddArc($tagRect.Right - $tagRadius, $tagRect.Y, $tagRadius, $tagRadius, 270, 90)
        $tagPath.AddArc($tagRect.Right - $tagRadius, $tagRect.Bottom - $tagRadius, $tagRadius, $tagRadius, 0, 90)
        $tagPath.AddArc($tagRect.X, $tagRect.Bottom - $tagRadius, $tagRadius, $tagRadius, 90, 90)
        $tagPath.CloseFigure()
        $graphics.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)), $tagPath)
        $graphics.DrawPath((New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(220, 226, 239), 1)), $tagPath)
        $graphics.DrawString($tag, $tagFont, $navyBrush, $tagRect.X + 16, $tagRect.Y + 11)
        $tagX += $tagRect.Width + 14
        $tagPath.Dispose()
    }

    $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Copy-Item $outputPath (Join-Path $repoRoot 'html-to-png\docs\output-example.png') -Force

    $tagFont.Dispose()
    $cardValueFont.Dispose()
    $cardTitleFont.Dispose()
    $cardLabelFont.Dispose()
    $bodyFont.Dispose()
    $headlineFont.Dispose()
    $eyebrowFont.Dispose()
    $cardPen.Dispose()
    $orangeBrush.Dispose()
    $mutedBrush.Dispose()
    $navyBrush.Dispose()
    $whiteBrush.Dispose()
    $eyebrowBrush.Dispose()
    $eyebrowPath.Dispose()
    $background.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

function New-HtmlToPdfPreview {
    $outputPath = Join-Path $previewRoot 'html-to-pdf.png'
    $bitmap = New-Object System.Drawing.Bitmap 1440, 900
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $background = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle 0, 0, 1440, 900),
        ([System.Drawing.Color]::FromArgb(245, 249, 255)),
        ([System.Drawing.Color]::FromArgb(255, 247, 240)),
        45
    )

    $graphics.FillRectangle($background, 0, 0, 1440, 900)

    $ink = [System.Drawing.Color]::FromArgb(30, 41, 59)
    $red = [System.Drawing.Color]::FromArgb(220, 38, 38)
    $muted = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $cardBorder = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $chip = [System.Drawing.Color]::FromArgb(15, 23, 42)

    $chipBrush = New-Object System.Drawing.SolidBrush $chip
    $inkBrush = New-Object System.Drawing.SolidBrush $ink
    $mutedBrush = New-Object System.Drawing.SolidBrush $muted
    $redBrush = New-Object System.Drawing.SolidBrush $red
    $whiteBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $cardPen = New-Object System.Drawing.Pen $cardBorder, 2

    $chipRect = New-Object System.Drawing.Rectangle 80, 70, 330, 54
    $chipPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $radius = 26
    $chipPath.AddArc($chipRect.X, $chipRect.Y, $radius, $radius, 180, 90)
    $chipPath.AddArc($chipRect.Right - $radius, $chipRect.Y, $radius, $radius, 270, 90)
    $chipPath.AddArc($chipRect.Right - $radius, $chipRect.Bottom - $radius, $radius, $radius, 0, 90)
    $chipPath.AddArc($chipRect.X, $chipRect.Bottom - $radius, $radius, $radius, 90, 90)
    $chipPath.CloseFigure()
    $graphics.FillPath($chipBrush, $chipPath)

    $eyebrowFont = New-Object System.Drawing.Font 'Segoe UI', 20, ([System.Drawing.FontStyle]::Bold)
    $headlineFont = New-Object System.Drawing.Font 'Segoe UI', 54, ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Object System.Drawing.Font 'Segoe UI', 22
    $cardLabelFont = New-Object System.Drawing.Font 'Segoe UI', 16
    $cardTitleFont = New-Object System.Drawing.Font 'Segoe UI', 22, ([System.Drawing.FontStyle]::Bold)
    $cardValueFont = New-Object System.Drawing.Font 'Segoe UI', 26, ([System.Drawing.FontStyle]::Bold)
    $tagFont = New-Object System.Drawing.Font 'Segoe UI', 16

    $graphics.DrawString('script-service preview', $eyebrowFont, $whiteBrush, 104, 80)
    $graphics.DrawString("Export local HTML`r`nto a PDF", $headlineFont, $inkBrush, 80, 160)
    $graphics.DrawString('html-to-pdf uses the browser print pipeline to export a local HTML file into a clean PDF document, then moves it safely to the target path.', $bodyFont, $inkBrush, (New-Object System.Drawing.RectangleF 80, 320, 1120, 90))

    $cardRects = @(
        (New-Object System.Drawing.Rectangle 80, 470, 390, 180),
        (New-Object System.Drawing.Rectangle 525, 470, 390, 180),
        (New-Object System.Drawing.Rectangle 970, 470, 390, 180)
    )
    $cardLabels = @('Input', 'Output', 'Engine')
    $cardTitles = @('Local HTML', 'PDF document', 'Headless browser print')
    $cardValues = @('.html / .htm', '.pdf', 'Edge / Chrome')

    for ($i = 0; $i -lt $cardRects.Count; $i++) {
        $cardRect = $cardRects[$i]
        $cardPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $cardRadius = 28
        $cardPath.AddArc($cardRect.X, $cardRect.Y, $cardRadius, $cardRadius, 180, 90)
        $cardPath.AddArc($cardRect.Right - $cardRadius, $cardRect.Y, $cardRadius, $cardRadius, 270, 90)
        $cardPath.AddArc($cardRect.Right - $cardRadius, $cardRect.Bottom - $cardRadius, $cardRadius, $cardRadius, 0, 90)
        $cardPath.AddArc($cardRect.X, $cardRect.Bottom - $cardRadius, $cardRadius, $cardRadius, 90, 90)
        $cardPath.CloseFigure()
        $graphics.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(252, 253, 255))), $cardPath)
        $graphics.DrawPath($cardPen, $cardPath)
        $graphics.DrawString($cardLabels[$i], $cardLabelFont, $mutedBrush, $cardRect.X + 26, $cardRect.Y + 26)
        $graphics.DrawString($cardTitles[$i], $cardTitleFont, $inkBrush, $cardRect.X + 26, $cardRect.Y + 64)
        $graphics.DrawString($cardValues[$i], $cardValueFont, $redBrush, $cardRect.X + 26, $cardRect.Y + 112)
        $cardPath.Dispose()
    }

    $tags = @('Windows', 'Edge / Chrome', 'PowerShell', 'PDF export')
    $tagX = 80
    foreach ($tag in $tags) {
        $size = $graphics.MeasureString($tag, $tagFont)
        $tagRect = New-Object System.Drawing.Rectangle ([int]$tagX), 730, ([int]($size.Width + 34)), 50
        $tagPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $tagRadius = 24
        $tagPath.AddArc($tagRect.X, $tagRect.Y, $tagRadius, $tagRadius, 180, 90)
        $tagPath.AddArc($tagRect.Right - $tagRadius, $tagRect.Y, $tagRadius, $tagRadius, 270, 90)
        $tagPath.AddArc($tagRect.Right - $tagRadius, $tagRect.Bottom - $tagRadius, $tagRadius, $tagRadius, 0, 90)
        $tagPath.AddArc($tagRect.X, $tagRect.Bottom - $tagRadius, $tagRadius, $tagRadius, 90, 90)
        $tagPath.CloseFigure()
        $graphics.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)), $tagPath)
        $graphics.DrawPath((New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(220, 226, 239), 1)), $tagPath)
        $graphics.DrawString($tag, $tagFont, $inkBrush, $tagRect.X + 16, $tagRect.Y + 11)
        $tagX += $tagRect.Width + 14
        $tagPath.Dispose()
    }

    $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Copy-Item $outputPath (Join-Path $repoRoot 'html-to-pdf\docs\pdf-export.png') -Force

    $tagFont.Dispose()
    $cardValueFont.Dispose()
    $cardTitleFont.Dispose()
    $cardLabelFont.Dispose()
    $bodyFont.Dispose()
    $headlineFont.Dispose()
    $eyebrowFont.Dispose()
    $cardPen.Dispose()
    $redBrush.Dispose()
    $mutedBrush.Dispose()
    $inkBrush.Dispose()
    $whiteBrush.Dispose()
    $chipBrush.Dispose()
    $chipPath.Dispose()
    $background.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

$npmCliCleanLines = @(
    '[1/6] Stop Codex processes...',
    '[2/6] Verify npm cache...',
    '[info] Content verified: 1182 (386435238 bytes)',
    '[3/6] Clean npm cache...',
    '[4/6] Remove temp @openai/.codex-* directories...',
    '[info] Found 1 temp directory: .codex-43zIZMD2',
    '[5/6] Skip reinstall. Use -Reinstall if needed.',
    '[6/6] Check codex version...',
    '[info] Current codex version: codex-cli 0.141.0',
    '[success] Cleanup finished successfully.'
)

$projectCleanerLines = @(
    'Name           SizeMB  FullName',
    'dist            82.4   E:\demo\app\dist',
    '.next           61.1   E:\demo\site\.next',
    '__pycache__      8.7   E:\demo\worker\__pycache__',
    '.pytest_cache    1.2   E:\demo\api\.pytest_cache',
    ' ',
    '[info] Default mode scans only, no delete action',
    '[info] Use -Clean to remove matched cache directories',
    '[info] Use -WhatIf to preview delete actions',
    '[success] Scan completed.'
)

New-TerminalPreview -OutputPath (Join-Path $previewRoot 'codex-windows-repair.png') -Title 'codex-windows-repair' -Lines $npmCliCleanLines
Copy-Item (Join-Path $previewRoot 'codex-windows-repair.png') (Join-Path $repoRoot 'codex-windows-repair\docs\codex-clean-result.png') -Force

New-TerminalPreview -OutputPath (Join-Path $previewRoot 'project-cleaner.png') -Title 'project-cleaner' -Lines $projectCleanerLines
Copy-Item (Join-Path $previewRoot 'project-cleaner.png') (Join-Path $repoRoot 'project-cleaner\docs\scan-result.png') -Force

New-HtmlToPngPreview
New-HtmlToPdfPreview

Write-Host 'Preview assets generated successfully.'
