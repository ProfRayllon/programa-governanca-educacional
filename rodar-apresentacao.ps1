$ErrorActionPreference = 'Stop'

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Port = 8000
$HtmlFile = 'Programa de Governanca Educacional Municipal.dc.html'
$EncodedHtmlFile = [uri]::EscapeDataString($HtmlFile)
$Url = "http://127.0.0.1:$Port/$EncodedHtmlFile"

$server = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
  Where-Object { $_.State -eq 'Listen' } |
  Select-Object -First 1

if (-not $server) {
  Start-Process -FilePath 'python' `
    -ArgumentList @('-m', 'http.server', "$Port", '--bind', '127.0.0.1') `
    -WorkingDirectory $ProjectDir `
    -WindowStyle Hidden

  Start-Sleep -Seconds 1
}

$edgePaths = @(
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)

$chromePaths = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
)

$browser = ($edgePaths + $chromePaths) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $browser) {
  Start-Process $Url
  exit
}

if ($browser -like '*msedge.exe') {
  Start-Process -FilePath $browser -ArgumentList @('--kiosk', $Url, '--edge-kiosk-type=fullscreen')
} else {
  Start-Process -FilePath $browser -ArgumentList @('--kiosk', $Url)
}
