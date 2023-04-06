# Benutzer auffordern, Start- und End-IP-Adresse einzugeben
$startIPString = Read-Host "Geben Sie die Start-IP-Adresse ein"
$endIPString = Read-Host "Geben Sie die End-IP-Adresse ein"

# Konvertieren Sie die IP-Adressen in ein numerisches Format
$startIPNum = [System.Net.IPAddress]::Parse($startIPString).GetAddressBytes()
$endIPNum = [System.Net.IPAddress]::Parse($endIPString).GetAddressBytes()

# Schleife durch alle IP-Adressen zwischen Start- und End-IP-Adresse

$desktopPath = [Environment]::GetFolderPath("Desktop")
$filePath = Join-Path $desktopPath "ip_scan.log"
New-Item -Path $filePath -ItemType File -Force |Out-Null
$currentIPNum = $startIPNum


while ($currentIPNum[0] -le $endIPNum[0] -and 
       $currentIPNum[1] -le $endIPNum[1] -and 
       $currentIPNum[2] -le $endIPNum[2] -and 
       $currentIPNum[3] -le $endIPNum[3]) {
    $currentIP = [System.Net.IPAddress]::new($currentIPNum)
    
    # Zeigen Sie an, welche IP-Adresse gerade gescannt wird
    Write-Host -ForegroundColor DarkGray "Scanne IP-Adresse: $($currentIP.ToString())"
    
    # Prüfen Sie, ob der Host erreichbar ist, indem Sie versuchen, ihn zu pingen
    if (Test-Connection -ComputerName $currentIP.ToString() -Count 1 -Quiet) {
        Write-Host -ForegroundColor Green "             Host: $($currentIP.ToString())"

        try {
            # Auflösen des Hostnamens für die gefundene IP-Adresse
            $hostName = "[" + [System.Net.Dns]::GetHostEntry($currentIP).HostName + "]"
            Write-Host -ForegroundColor Green "         Hostname: $hostName"
        }
        catch {
            # Unterdrücken Sie den Fehler, wenn der Hostname nicht gefunden werden kann
            $hostName = ""
        }

        # Ermitteln Sie die MAC-Adresse des gefundenen Hosts
        $macAddress = (Get-NetNeighbor -IPAddress $currentIP.ToString()).LinkLayerAddress
        Write-Host -ForegroundColor Green "              MAC: $macAddress"
        Write-Host ""
        
        # Schreiben Sie den gefundenen Host, Hostnamen und MAC-Adresse in die Log-Datei
        $logEntry = "$($currentIP.ToString()) [$macAddress] $hostName"
        Add-Content -Path $filePath -Value $logEntry
    }
    
    # Inkrementieren Sie die IP-Adresse um 1
    $currentIPNum[3]++
    
    if ($currentIPNum[3] -gt 254) {
        $currentIPNum[2]++
        $currentIPNum[3] = 0
        
        if ($currentIPNum[2] -gt 254) {
            $currentIPNum[1]++
            $currentIPNum[2] = 0
            
            if ($currentIPNum[1] -gt 254) {
                $currentIPNum[0]++
                $currentIPNum[1] = 0
            }
        }
    }
}
