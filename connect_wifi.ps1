$ErrorActionPreference = 'Continue'
$proj = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $proj

Write-Host "`n[1/4] Mengaktifkan mode TCP ADB..." -ForegroundColor Cyan
adb tcpip 5555 2>$null
Start-Sleep -Seconds 1

# Ambil device network (IP:port) yang sudah terhubung
$adbLines = adb devices | Where-Object { $_ -match '^\S+\s+device$' }
$netDevices = $adbLines | Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}:\d+' }

if ($netDevices.Count -eq 0) {
    $ip = Read-Host "`nTidak ada device WiFi. Masukkan IP HP (misal 192.168.30.106)"
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

Write-Host "`n[2/4] Daftar device terdeteksi:" -ForegroundColor Cyan
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

# Deteksi IP PC host di jaringan Wi-Fi
Write-Host "`n[3/4] Mendeteksi IP PC host untuk Backend..." -ForegroundColor Cyan
$pcIp = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    ($_.InterfaceAlias -like '*Wi-Fi*' -or $_.InterfaceAlias -like '*WLAN*') -and
    $_.IPAddress -notlike '169.254*' -and $_.IPAddress -notlike '127*'
}).IPAddress | Select-Object -First 1

if (-not $pcIp) {
    $pcIp = "192.168.30.105"
}

$apiUrl = "http://$pcIp`:8000"
Write-Host "  Host Backend : $apiUrl" -ForegroundColor Green

# Port reverse untuk akses via localhost
adb -s $target reverse tcp:8000 tcp:8000 2>$null

Write-Host "`n[4/4] Menjalankan flutter run -d $target ..." -ForegroundColor Green
flutter run -d $target --dart-define="API_BASE_URL=$apiUrl"

