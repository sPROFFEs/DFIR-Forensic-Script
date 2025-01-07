
$outputFolder = Join-Path $PSScriptRoot "OUTPUT"


if (-not (Test-Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory | Out-Null
}


$outputFormat = Read-Host "Enter desired output format (json/csv)"
if ($outputFormat -notin @("json", "csv")) {
    Write-Host "Invalid format. Defaulting to JSON." -ForegroundColor Yellow
    $outputFormat = "json"
}


function Run-And-Export {
    param (
        [string]$Command,
        [string]$OutputFile
    )
    
    try {
        $output = Invoke-Expression $Command | Out-String
        

        $outputFilePath = Join-Path $outputFolder $OutputFile
        Write-Host "Saving output to: $outputFilePath"

        if ($outputFormat -eq "json") {

            $jsonOutput = [PSCustomObject]@{ Output = $output }
            

            $jsonFormatted = $jsonOutput | ConvertTo-Json -Depth 10

            Set-Content -Path $outputFilePath -Value $jsonFormatted
        } elseif ($outputFormat -eq "csv") {
            $csvOutput = [PSCustomObject]@{ Output = $output }
            $csvOutput | Export-Csv -Path $outputFilePath -NoTypeInformation
        }
    } catch {

        Write-Host "Error executing the command: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 1. Run ipconfig /all
Run-And-Export -Command "ipconfig /all" -OutputFile "Configuracion_red.$outputFormat"

# 2. Run ipconfig /displaydns
Run-And-Export -Command "ipconfig /displaydns" -OutputFile "DNS_consultas.$outputFormat"

# 3. Run nbtstat -s
Run-And-Export -Command "nbtstat -s" -OutputFile "Sesionnetbios.$outputFormat"

# 4. Run nbtstat -c
Run-And-Export -Command "nbtstat -c" -OutputFile "Cachenetbios.$outputFormat"

# 5. Run netstat -an and filter for listening and established
Run-And-Export -Command "netstat -an | findstr /i 'listening established'" -OutputFile "Conexionesactivas.$outputFormat"

# 6. Run netstat -anob
Run-And-Export -Command "netstat -anob" -OutputFile "AplicacionesPuertosAbiertos.$outputFormat"

# 7. Run netstat -r
Run-And-Export -Command "netstat -r" -OutputFile "Tablarutas.$outputFormat"

# 8. Run netstat -ano
Run-And-Export -Command "netstat -ano" -OutputFile "Conexionesactivas.$outputFormat"

# 9. Run type hosts file
Run-And-Export -Command "type C:\\Windows\\System32\\drivers\\etc\\hosts" -OutputFile "Hosts.$outputFormat"

# 10. Run net file
Run-And-Export -Command "net file" -OutputFile "transferencia-ficheros-sobre-netbios.$outputFormat"

# 11. Run arp -a
Run-And-Export -Command "arp -a" -OutputFile "arp-cache.$outputFormat"

# 12. Run route PRINT
Run-And-Export -Command "route PRINT" -OutputFile "TablaRutas.$outputFormat"

# 13. Run net use
Run-And-Export -Command "net use" -OutputFile "UnidadesMapeadas.$outputFormat"

# 14. Run net share
Run-And-Export -Command "net share" -OutputFile "CarpetasCompartidas.$outputFormat"

# 15. Run net use (again)
Run-And-Export -Command "net use" -OutputFile "recursos_compartidos.$outputFormat"

# 16. Run nbtstat -n
Run-And-Export -Command "nbtstat -n" -OutputFile "usuarios-recurso-compartidos.$outputFormat"

# 17. Run net USERS
Run-And-Export -Command "net USERS" -OutputFile "Usuarios-locales-y-remotos.$outputFormat"

# 18. Run net sessions
Run-And-Export -Command "net sessions" -OutputFile "Usuarios-remotos-ip.$outputFormat"

# 19. Run doskey /history
Run-And-Export -Command "doskey /history" -OutputFile "HistoricoCMD.$outputFormat"

# 20. Get-Service para obtener los servicios en ejecución
Run-And-Export -Command "Get-Service" -OutputFile "servicios-ejecucion.$outputFormat"

# 21. Get-CimInstance para obtener el tiempo de actividad
Run-And-Export -Command {
    $uptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $uptime = (Get-Date) - $uptime
    $uptime | Out-String
} -OutputFile "Tiempoencendido.$outputFormat"

# 22. Run tasklist.exe
Run-And-Export -Command "tasklist.exe" -OutputFile "Procesosenuso.$outputFormat"

# Additional software-dependent commands with specified paths

# 23. Run pslist.exe
Run-And-Export -Command "$PSScriptRoot\\pslist.exe /accepteula" -OutputFile "Procesos.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\pslist64.exe /accepteula" -OutputFile "Procesos_x64.$outputFormat"

# 24. Run cprocess.exe
Run-And-Export -Command "$PSScriptRoot\\cprocess.exe /stext Procesosdeusuarios.txt" -OutputFile "Procesosdeusuarios.$outputFormat"

# 26. Run listdlls.exe
Run-And-Export -Command "$PSScriptRoot\\listdlls.exe /accepteula" -OutputFile "Procesosdependencias.$outputFormat"

# 27. Run openports.exe
Run-And-Export -Command "$PSScriptRoot\\openports.exe -path" -OutputFile "Mapa_agrupado_puertos_procesos.$outputFormat"

# 28. Run Handle.exe
Run-And-Export -Command "$PSScriptRoot\\Handle.exe /accepteula" -OutputFile "Procesosmanejadores.$outputFormat"

# 29. Run promiscdetect.exe
Run-And-Export -Command "$PSScriptRoot\\promiscdetect.exe" -OutputFile "Adaptadorespromiscuos.$outputFormat"

# 30. Run urlprotocolview.exe
Run-And-Export -Command "$PSScriptRoot\\urlprotocolview.exe /stext RedProtocolos.txt" -OutputFile "RedProtocolos.$outputFormat"

# 31. Run openedfilesview.exe
Run-And-Export -Command "$PSScriptRoot\\openedfilesview.exe /stext Ficherosabiertos.txt" -OutputFile "Ficherosabiertos.$outputFormat"

# 32. Run psfile.exe
Run-And-Export -Command "$PSScriptRoot\\psfile.exe /accepteula" -OutputFile "Ficheros_remotos_abiertos.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psfile64.exe /accepteula" -OutputFile "Ficheros_remotos_abiertos_x64.$outputFormat"

# 33. Run logonsessions.exe
Run-And-Export -Command "$PSScriptRoot\\logonsessions.exe /accepteula" -OutputFile "Sesiones-activas.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\logonsessions64.exe /accepteula" -OutputFile "Sesiones-activas_x64.$outputFormat"

# 34. Run psGetsid.exe
Run-And-Export -Command "$PSScriptRoot\\psGetsid.exe" -OutputFile "Usuarios-sid.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psGetsid64.exe" -OutputFile "Usuarios-sid_x64.$outputFormat"

# 36. Run InsideClipboard.exe
Run-And-Export -Command "$PSScriptRoot\\InsideClipboard.exe /stext" -OutputFile "Informacion_portapapeles.$outputFormat"

Write-Host "Script executed. Outputs saved in $outputFolder" -ForegroundColor Green
