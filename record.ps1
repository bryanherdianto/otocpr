$adb = "D:\Android\Sdk\platform-tools\adb.exe"
$duration = 40  # Total recording duration in seconds (gives 4.5s outro on Home)
$remotePath = "/sdcard/autocpr_walkthrough.mp4"
$localPath = "./autocpr_walkthrough.mp4"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Starting Automated High-Fidelity Walkthrough Recording   " -ForegroundColor Cyan
Write-Host " Features: Proper Home Scroll + Real-Time Details + Logs + Return to Home" -ForegroundColor Cyan
Write-Host " Duration: $duration seconds | Device: emulator-5554" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Clean up any leftover file
& $adb shell "rm -f $remotePath" 2>$null

# 1. Start background screen recording with automatic finalization
$recordJob = Start-Job -ScriptBlock {
    param($adbPath, $limit, $dest)
    & $adbPath shell screenrecord --time-limit $limit --bit-rate 16000000 --size 1080x2400 $dest
} -ArgumentList $adb, $duration, $remotePath

Start-Sleep -Milliseconds 1500

# ---------------------------------------------------------------------------------
# STAGE 1: HOME SCREEN (Robotic System, GPS Map, Slow Scroll without touching map)
# ---------------------------------------------------------------------------------
Write-Host "[1/5] Home Screen: Showing Equipment & Map..." -ForegroundColor Yellow
# Tap Home tab (x: 135, y: 2270)
& $adb shell "input tap 135 2270"
Start-Sleep -Milliseconds 1200

Write-Host "      -> Slow scrolling down to Machine Logs (swiping above map)..." -ForegroundColor Gray
# Swipe in the area ABOVE the map (y: 850 up to y: 250) so the map gesture is never intercepted
& $adb shell "input swipe 540 850 540 250 1200"
Start-Sleep -Milliseconds 1200

Write-Host "      -> Slow scrolling back up to top..." -ForegroundColor Gray
& $adb shell "input swipe 540 350 540 1350 1000"
Start-Sleep -Milliseconds 1000

# ---------------------------------------------------------------------------------
# STAGE 2: TELEMETRY TAB & DEEP DIVE INTO DETAILS SCREEN
# ---------------------------------------------------------------------------------
Write-Host "[2/5] Switching to Telemetry Tab..." -ForegroundColor Yellow
# Tap Tab 1: Telemetry (x: 405, y: 2270)
& $adb shell "input tap 405 2270"
Start-Sleep -Milliseconds 1200

Write-Host "      -> Clicking 'Instant Force' Real-Time Data Card..." -ForegroundColor Yellow
& $adb shell "input tap 260 670"
Start-Sleep -Milliseconds 1500

Write-Host "      -> [Details Screen] Viewing Waveform Chart & Selecting 5m..." -ForegroundColor Green
# Tap 5m timeframe selector tab
& $adb shell "input tap 420 160"
Start-Sleep -Milliseconds 800

Write-Host "      -> [Details Screen] Slow scrolling down to Summary..." -ForegroundColor Gray
& $adb shell "input swipe 540 1600 540 900 1200"
Start-Sleep -Milliseconds 1000

Write-Host "      -> [Details Screen] Slow scrolling back up..." -ForegroundColor Gray
& $adb shell "input swipe 540 900 540 1600 1200"
Start-Sleep -Milliseconds 800

Write-Host "      -> [Details Screen] Navigating back to Telemetry Overview..." -ForegroundColor Yellow
& $adb shell "input keyevent 4"
Start-Sleep -Milliseconds 1000

Write-Host "      -> [Telemetry Screen] Slow scrolling down..." -ForegroundColor Gray
& $adb shell "input swipe 540 1600 540 800 1200"
Start-Sleep -Milliseconds 1000

Write-Host "      -> [Telemetry Screen] Slow scrolling back up..." -ForegroundColor Gray
& $adb shell "input swipe 540 800 540 1600 1200"
Start-Sleep -Milliseconds 1000

# ---------------------------------------------------------------------------------
# STAGE 3: AI DIAGNOSTICS TAB
# ---------------------------------------------------------------------------------
Write-Host "[3/5] Switching to AI Diagnostics Tab..." -ForegroundColor Yellow
# Tap Tab 2: AI (x: 675, y: 2270)
& $adb shell "input tap 675 2270"
Start-Sleep -Milliseconds 1200

Write-Host "      -> Slow scrolling down to Window History & Session Index..." -ForegroundColor Gray
& $adb shell "input swipe 540 1700 540 800 1300"
Start-Sleep -Milliseconds 1200

Write-Host "      -> Slow scrolling back up..." -ForegroundColor Gray
& $adb shell "input swipe 540 800 540 1700 1300"
Start-Sleep -Milliseconds 1000

# ---------------------------------------------------------------------------------
# STAGE 4: MACHINE LOGS TAB
# ---------------------------------------------------------------------------------
Write-Host "[4/5] Switching to Machine Logs Tab..." -ForegroundColor Yellow
# Tap Tab 3: Logs (x: 945, y: 2270)
& $adb shell "input tap 945 2270"
Start-Sleep -Milliseconds 1200

Write-Host "      -> Filtering by AI logs..." -ForegroundColor Gray
# Tap 'AI' filter tab (x: 830, y: 145)
& $adb shell "input tap 830 145"
Start-Sleep -Milliseconds 1000

Write-Host "      -> Slow scrolling down logs list..." -ForegroundColor Gray
& $adb shell "input swipe 540 1600 540 900 1200"
Start-Sleep -Milliseconds 1000

Write-Host "      -> Opening Log Details Bottom Sheet..." -ForegroundColor Yellow
# Tap top log item (x: 540, y: 250)
& $adb shell "input tap 540 250"
Start-Sleep -Milliseconds 1500

Write-Host "      -> Closing Bottom Sheet..." -ForegroundColor Gray
& $adb shell "input keyevent 4"
Start-Sleep -Milliseconds 1000

# ---------------------------------------------------------------------------------
# STAGE 5: RETURN TO HOME DASHBOARD (FINAL SHOWCASE)
# ---------------------------------------------------------------------------------
Write-Host "[5/5] Returning to Home Dashboard..." -ForegroundColor Yellow
# Tap Tab 0: Home (x: 135, y: 2270)
& $adb shell "input tap 135 2270"
Start-Sleep -Milliseconds 2500

# Wait for screenrecord job to cleanly finish its time limit
Write-Host "Finalizing video encoder and writing MP4 headers..." -ForegroundColor Cyan
Wait-Job $recordJob -Timeout 10 | Out-Null
Receive-Job $recordJob | Out-Null
Remove-Job $recordJob -Force

Start-Sleep -Seconds 1

# Pull output to PC
Write-Host "Pulling completed video to PC..." -ForegroundColor Cyan
& $adb pull $remotePath $localPath
& $adb shell "rm -f $remotePath" 2>$null

if (Test-Path $localPath) {
    $fileInfo = Get-Item $localPath
    $sizeMb = [math]::Round($fileInfo.Length / 1MB, 2)
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " SUCCESS! Walkthrough Video Created Successfully:" -ForegroundColor Green
    Write-Host " File: $($fileInfo.FullName) ($sizeMb MB)" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "Error: Could not retrieve video from device." -ForegroundColor Red
}