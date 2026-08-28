# Copies generated PNGs from the Cursor assets folder into this repo.
# powershell -File scripts/copy-from-cursor-assets.ps1

$ErrorActionPreference = "Stop"
$src = "C:\Users\Kennychan\.cursor\projects\d-cursor-ui-ux-pro-max-skill\assets"
$root = Split-Path -Parent $PSScriptRoot
$mapPath = Join-Path $PSScriptRoot "copy-map.json"

if (-not (Test-Path -LiteralPath $src)) {
  throw "Source assets folder not found: $src"
}

foreach ($d in @("posters", "storyboards", "fusions")) {
  New-Item -ItemType Directory -Force -Path (Join-Path $root $d) | Out-Null
}

$map = Get-Content -LiteralPath $mapPath -Encoding UTF8 -Raw | ConvertFrom-Json

function Copy-Named([string]$from, [string]$toRel) {
  $fromPath = Join-Path $src $from
  $toPath = Join-Path $root $toRel
  if (-not (Test-Path -LiteralPath $fromPath)) {
    Write-Warning "Missing: $from"
    return
  }
  Copy-Item -LiteralPath $fromPath -Destination $toPath -Force
  Write-Host "OK  $toRel"
}

foreach ($section in @("posters", "fusions", "storyboards_ascii")) {
  $obj = $map.$section
  $obj.PSObject.Properties | ForEach-Object {
    Copy-Named $_.Name $_.Value
  }
}

# Unicode filenames: pick by substring in the live directory listing.
function Copy-Contains([string]$fragment, [string]$toRel, [string]$prefix = "") {
  $hit = Get-ChildItem -LiteralPath $src -File | Where-Object {
    ($prefix -eq "" -or $_.Name.StartsWith($prefix)) -and ($_.Name.IndexOf($fragment) -ge 0)
  } | Select-Object -First 1
  if (-not $hit) {
    Write-Warning "No match for fragment: $fragment"
    return
  }
  Copy-Item -LiteralPath $hit.FullName -Destination (Join-Path $root $toRel) -Force
  Write-Host "OK  $toRel"
}

Copy-Contains ([char]0x662D + [char]0x541B + [char]0x51FA + [char]0x585E) "storyboards/zhaojun-anime-4color-editorial-6panel.png" "Anime Manga"
Copy-Contains ([char]0x5211 + [char]0x5075 + [char]0x5287) "storyboards/crime-anime-4color-editorial-6panel.png" "Anime Manga"
Copy-Contains ([char]0x5217 + [char]0x5BE7) "storyboards/lenin-anime-4color-editorial-6panel.png" "Anime Manga"
Copy-Contains ([char]0x62FF + [char]0x7834 + [char]0x502B) "storyboards/napoleon-anime-4color-editorial-6panel.png"

# Oil crime v1 has 打光攝影; v2 has 打光 then 雜誌 (no 攝影 in that slot).
$oil = Get-ChildItem -LiteralPath $src -File | Where-Object { $_.Name.StartsWith("Oil Painting") }
foreach ($f in $oil) {
  if ($f.Name.IndexOf([char]0x651D + [char]0x5F71) -ge 0) {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $root "storyboards/crime-oil-cinematic-editorial-6panel-v1.png") -Force
    Write-Host "OK  storyboards/crime-oil-cinematic-editorial-6panel-v1.png"
  } else {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $root "storyboards/crime-oil-cinematic-editorial-6panel-v2.png") -Force
    Write-Host "OK  storyboards/crime-oil-cinematic-editorial-6panel-v2.png"
  }
}

Write-Host "Done."
