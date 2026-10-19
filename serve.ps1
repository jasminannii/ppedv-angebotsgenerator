# Minimaler statischer Webserver fuer die Vorschau (nur localhost)
param([int]$Port = 8765, [string]$Root = $PSScriptRoot)
$Root = (Resolve-Path $Root).Path
$types = @{ '.html'='text/html; charset=utf-8'; '.js'='text/javascript; charset=utf-8'; '.css'='text/css; charset=utf-8';
  '.json'='application/json; charset=utf-8'; '.png'='image/png'; '.pdf'='application/pdf'; '.svg'='image/svg+xml' }
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Host "Serving $Root on http://localhost:$Port/"
while ($l.IsListening) {
  $c = $l.GetContext()
  $rel = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath.TrimStart('/'))
  if (-not $rel) { $rel = 'index.html' }
  $file = [IO.Path]::GetFullPath((Join-Path $Root $rel))
  if (Test-Path $file -PathType Container) { $file = Join-Path $file 'index.html' }
  if ($file.StartsWith($Root) -and (Test-Path $file -PathType Leaf)) {
    $bytes = [IO.File]::ReadAllBytes($file)
    $ct = $types[[IO.Path]::GetExtension($file).ToLower()]; if (-not $ct) { $ct = 'application/octet-stream' }
    $c.Response.ContentType = $ct
    $c.Response.Headers.Add('Cache-Control', 'no-store')
    $c.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else { $c.Response.StatusCode = 404 }
  $c.Response.Close()
}
