# 탭 카운터 데스크톱 exe 빌드 스크립트
# 사용법: PowerShell에서 프로젝트 루트로 이동 후 실행
#   .\build\make-dist.ps1
#
# electron-packager/electron-builder의 zip 압축해제 단계가 이 환경에서
# 조용히 실패하는 문제가 있어(node extract-zip 이슈), Electron 배포본을
# node_modules/electron/dist에서 직접 복사하는 방식으로 우회한다.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$appName = "탭카운터"
$distRoot = Join-Path $root "dist"
$outDir = Join-Path $distRoot "$appName-win32-x64"

Write-Host "기존 dist 정리..."
Get-Process | Where-Object { $_.Path -like "*$root*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Remove-Item $distRoot -Recurse -Force -ErrorAction SilentlyContinue

$electronDist = Join-Path $root "node_modules\electron\dist"
if (-not (Test-Path (Join-Path $electronDist "electron.exe"))) {
    Write-Host "node_modules/electron/dist에 electron.exe가 없습니다. npm install 후 재시도하세요."
    Write-Host "(만약 npm install 후에도 없다면, 아래로 수동 압축해제)"
    $zip = Get-ChildItem "$env:LOCALAPPDATA\electron\Cache" -Recurse -Filter "electron-v*-win32-x64.zip" | Select-Object -First 1
    if ($zip) {
        Write-Host "수동 압축해제: $($zip.FullName)"
        Expand-Archive -Path $zip.FullName -DestinationPath $electronDist -Force
    } else {
        throw "Electron 배포 zip을 찾을 수 없습니다. npm install을 먼저 실행하세요."
    }
}

Write-Host "앱 파일 복사..."
New-Item -ItemType Directory -Force -Path (Join-Path $outDir "resources\app") | Out-Null
Copy-Item "$electronDist\*" $outDir -Recurse -Force
Copy-Item "main.js", "index.html", "manifest.json", "sw.js", "icon.svg" (Join-Path $outDir "resources\app") -Force

@'
{
  "name": "tap-counter",
  "version": "1.0.0",
  "main": "main.js"
}
'@ | Set-Content -Encoding utf8 (Join-Path $outDir "resources\app\package.json")

Rename-Item (Join-Path $outDir "electron.exe") "$appName.exe"

Write-Host "아이콘/버전 정보 적용 (rcedit)..."
$rcedit = Join-Path $root "node_modules\rcedit\bin\rcedit-x64.exe"
$exe = Join-Path $outDir "$appName.exe"
& $rcedit $exe --set-icon (Join-Path $root "build\icon.ico") `
  --set-file-version "1.0.0" `
  --set-product-version "1.0.0" `
  --set-version-string "ProductName" $appName `
  --set-version-string "FileDescription" "탭 카운터"

Write-Host "압축..."
$zipOut = Join-Path $distRoot "${appName}_v1.0.zip"
Compress-Archive -Path $outDir -DestinationPath $zipOut -Force

Write-Host "완료: $zipOut"
