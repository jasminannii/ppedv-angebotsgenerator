# Erzeugt aus einer Angebots-JSON (gespeichert im Angebotsgenerator) ein PDF.
# Nutzung:  powershell -ExecutionPolicy Bypass -File export-pdf.ps1 -Json "angebote\kunde.json" [-Out "kunde.pdf"]
param(
  [Parameter(Mandatory = $true)][string]$Json,
  [string]$Out
)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Json = (Resolve-Path $Json).Path
if (-not $Out) {
  # Dateiname wie im Generator: "ANG-<Angebotsnummer>_<Unternehmen>.pdf"
  $d = [IO.File]::ReadAllText($Json, [Text.Encoding]::UTF8) | ConvertFrom-Json
  $firma = if ($d.kunde -and $d.kunde.firma) { ([string]$d.kunde.firma).Trim() } else { 'Kunde' }
  # Angebotsnummer = Kundennummer
  $nr = if ($d.kunde -and $d.kunde.kundennr) { ([string]$d.kunde.kundennr).Trim() -replace '^(?i)ANG-?', '' } else { '' }
  if (-not $nr) { $nr = 'ohne-Nr' }
  $name = ('ANG-' + $nr + '_' + $firma) -replace '[\\/:*?"<>|]+', '-' -replace '\s+', ' '
  $Out = Join-Path (Split-Path -Parent $Json) ($name.Trim() + '.pdf')
}
$Out = [IO.Path]::GetFullPath($Out)

$browser = @(
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw 'Weder Edge noch Chrome gefunden.' }

$bytes = [IO.File]::ReadAllBytes($Json)
$b64 = [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
$url = ([Uri](Join-Path $here 'index.html')).AbsoluteUri + '#data=' + $b64

# Erst in einen Temp-Ordner drucken, dann an das Ziel kopieren (vermeidet Sperren in OneDrive-Ordnern)
$tmpDir = Join-Path $env:TEMP ('angebot-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmpDir | Out-Null
$tmpPdf = Join-Path $tmpDir 'out.pdf'
$argList = @('--headless=new', '--disable-gpu', '--no-pdf-header-footer', '--virtual-time-budget=4000',
          "--user-data-dir=$tmpDir\profile", "--print-to-pdf=$tmpPdf", $url)
$p = Start-Process -FilePath $browser -ArgumentList $argList -PassThru -WindowStyle Hidden
if (-not $p.WaitForExit(60000)) { $p.Kill(); throw 'Zeitueberschreitung beim PDF-Druck.' }
if (-not (Test-Path $tmpPdf)) { throw 'PDF wurde nicht erzeugt.' }
Copy-Item $tmpPdf $Out -Force
Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "PDF erstellt: $Out"
