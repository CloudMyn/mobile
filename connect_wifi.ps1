$ErrorActionPreference = 'Continue'
$proj = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $proj

Write-Host "`n[1/3] Mengaktifkan mode TCP ADB..." -ForegroundColor Cyan
adb tcpip 5555 2>$null
Start-Sleep -Seconds 1

# Ambil device network (IP:port) yang sudah terhubung
$adbLines = adb devices | Where-Object { $_ -match '^\S+\s+device$' }
$netDevices = $adbLines | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}:\d+' }

if ($netDevices.Count -eq 0) {
    $ip = Read-Host "`nTidak ada device WiFi. Masukkan IP HP (misal 192.168.1.18)"
    if ($ip -notmatch '^\d{1,3}(\.\d{1,3}){3}$') {
        Write-Host "Format IP salah." -ForegroundColor Red
        exit 1
    }
    Write-Host "Menghubungkan ke $ip`:5555..." -ForegroundColor Yellow
    adb connect "$ip`:5555"
    Start-Sleep -Seconds 2
    $adbLines = adb devices | Where-Object { $_ -match '^\S+\s+device$' }
    $netDevices = $adbLines | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}:\d+' }
}

if ($netDevices.Count -eq 0) {
    Write-Host "`nGagal mendapatkan device WiFi. Pastikan HP di WiFi yang sama & USB sempat terhubung." -ForegroundColor Red
    exit 1
}

# Gabungkan semua device (USB + WiFi) untuk dipilih
$allDevices = $adbLines | ForEach-Object { ($_ -split '\s+')[0] }

Write-Host "`n[2/3] Daftar device terdeteksi:" -ForegroundColor Cyan
for ($i = 0; $i -lt $allDevices.Count; $i++) {
    $mark = if ($allDevices[$i] -match '^\d{1,3}(\.\d{1,3}){3}:\d+') { "(WiFi)" } else { "(USB)" }
    Write-Host "  [$i] $($allDevices[$i]) $mark"
}

$choice = Read-Host "`nPilih nomor device untuk flutter run"
if (-not ($choice -match '^\d+$') -or [int]$choice -ge $allDevices.Count) {
    Write-Host "Pilihan tidak valid." -ForegroundColor Red
    exit 1
}
$target = $allDevices[[int]$choice]

Write-Host "`n[3/3] Menjalankan flutter run -d $target ..." -ForegroundColor Green
flutter run -d $target
