@echo off
rem Angebots-JSON auf diese Datei ziehen -> PDF entsteht daneben.
if "%~1"=="" (
  echo Bitte eine Angebots-JSON-Datei auf "PDF erstellen.cmd" ziehen.
  pause
  exit /b 1
)
for %%F in (%*) do powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0export-pdf.ps1" -Json "%%~fF"
pause
