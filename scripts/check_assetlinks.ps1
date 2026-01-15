param(
  [string]$Url = "https://unconvoluted-prepreference-jeraldine.ngrok-free.dev/.well-known/assetlinks.json"
)

Write-Host "Checking $Url ..."
try {
  $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 15
} catch {
  Write-Error "Request failed: $_"
  exit 2
}

Write-Host "Status: $($resp.StatusCode)"
if ($resp.Headers['Content-Type']) { Write-Host "Content-Type: $($resp.Headers['Content-Type'])" }

if ($resp.Headers['Content-Type'] -notlike '*application/json*') {
  Write-Error "ERROR: Content-Type is not application/json"
  exit 3
}

if ($resp.Content -match 'delegate_permission/common.handle_all_urls') {
  Write-Host "OK: assetlinks.json looks valid (contains delegate_permission)"
  exit 0
} else {
  Write-Error "ERROR: assetlinks.json does not contain expected content"
  exit 4
}
