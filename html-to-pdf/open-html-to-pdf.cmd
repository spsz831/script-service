@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -STA -Command ^
 "Add-Type -AssemblyName System.Windows.Forms; $ofd=New-Object System.Windows.Forms.OpenFileDialog; $ofd.Filter='HTML Files (*.html;*.htm)|*.html;*.htm'; if($ofd.ShowDialog() -ne 'OK'){exit 0}; $sfd=New-Object System.Windows.Forms.SaveFileDialog; $sfd.Filter='PDF Files (*.pdf)|*.pdf'; $sfd.FileName=[System.IO.Path]::GetFileNameWithoutExtension($ofd.FileName)+'.pdf'; $sfd.InitialDirectory=Split-Path -Parent $ofd.FileName; if($sfd.ShowDialog() -ne 'OK'){exit 0}; & '%~dp0html-to-pdf.ps1' -InputHtml $ofd.FileName -OutputPdf $sfd.FileName"
if errorlevel 1 pause
