$outputFolder = Join-Path $PSScriptRoot "OUTPUT"

# Crear el directorio si no existe
if (-not (Test-Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory | Out-Null
}

# Solicitar el formato de salida (json/csv)
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
        # Ejecutar el comando y capturar la salida
        $output = Invoke-Expression $Command | Out-String

        # Limpiar la salida de caracteres adicionales
        $output = $output -replace "`r`n", "`n"  # Usar solo saltos de línea
        $output = $output.Trim() # Eliminar espacios en exceso

        # Procesar la salida de cada línea
        $formattedOutput = @{}
        $lineCounter = 1  # Contador para líneas no clave:valor
        $csvOutput = @()

        $output.Split("`n") | ForEach-Object {
            $line = $_.Trim()

            # Si la línea tiene un formato tipo "clave: valor", la procesamos
            if ($line -match '^(\S[\w\s-]+):\s*(\S.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()

                # Añadir al objeto final para JSON
                $formattedOutput[$key] = $value

                # También añadir la clave-valor al CSV, como fila
                $csvOutput += [PSCustomObject]@{ $key = $value }
            } else {
                # Si no es una línea de clave: valor, creamos una clave única para cada línea
                $formattedOutput["Line$lineCounter"] = $line

                # Para CSV, creamos una fila con la línea como "LineN"
                $csvOutput += [PSCustomObject]@{ Line = $line }
                $lineCounter++
            }
        }

        # Guardar el formato adecuado
        $outputFilePath = Join-Path $outputFolder $OutputFile
        Write-Host "Saving output to: $outputFilePath"

        # Si la salida es JSON
        if ($outputFormat -eq "json") {
            # Convertir el objeto a JSON con indentación
            $jsonFormatted = $formattedOutput | ConvertTo-Json -Depth 10
            $jsonFormatted | Out-File -FilePath $outputFilePath -Encoding utf8
        }

        # Si la salida es CSV
        if ($outputFormat -eq "csv") {
            # Exportar a CSV
            $csvOutput | Export-Csv -Path $outputFilePath -NoTypeInformation -Encoding UTF8
        }
    } catch {
        Write-Host "Error executing the command: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Ejecutar los comandos deseados y guardar los resultados
Run-And-Export -Command "ipconfig /all" -OutputFile "Configuracion_red.$outputFormat"
Run-And-Export -Command "ipconfig /displaydns" -OutputFile "DNS_consultas.$outputFormat"
Run-And-Export -Command "nbtstat -s" -OutputFile "Sesionnetbios.$outputFormat"
Run-And-Export -Command "nbtstat -c" -OutputFile "Cachenetbios.$outputFormat"
Run-And-Export -Command "netstat -an | findstr /i 'listening established'" -OutputFile "Conexionesactivas.$outputFormat"
Run-And-Export -Command "netstat -anob" -OutputFile "AplicacionesPuertosAbiertos.$outputFormat"
Run-And-Export -Command "netstat -r" -OutputFile "Tablarutas.$outputFormat"
Run-And-Export -Command "netstat -ano" -OutputFile "Conexionesactivas.$outputFormat"
Run-And-Export -Command "type C:\\Windows\\System32\\drivers\\etc\\hosts" -OutputFile "Hosts.$outputFormat"
Run-And-Export -Command "net file" -OutputFile "transferencia-ficheros-sobre-netbios.$outputFormat"
Run-And-Export -Command "arp -a" -OutputFile "arp-cache.$outputFormat"
Run-And-Export -Command "route PRINT" -OutputFile "TablaRutas.$outputFormat"
Run-And-Export -Command "net use" -OutputFile "UnidadesMapeadas.$outputFormat"
Run-And-Export -Command "net share" -OutputFile "CarpetasCompartidas.$outputFormat"
Run-And-Export -Command "net use" -OutputFile "recursos_compartidos.$outputFormat"
Run-And-Export -Command "nbtstat -n" -OutputFile "usuarios-recurso-compartidos.$outputFormat"
Run-And-Export -Command "net USERS" -OutputFile "Usuarios-locales-y-remotos.$outputFormat"
Run-And-Export -Command "net sessions" -OutputFile "Usuarios-remotos-ip.$outputFormat"
Run-And-Export -Command "doskey /history" -OutputFile "HistoricoCMD.$outputFormat"
Run-And-Export -Command "Get-Service" -OutputFile "servicios-ejecucion.$outputFormat"
Run-And-Export -Command {
    $uptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $uptime = (Get-Date) - $uptime
    $uptime | Out-String
} -OutputFile "Tiempoencendido.$outputFormat"
Run-And-Export -Command "tasklist.exe" -OutputFile "Procesosenuso.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\pslist.exe /accepteula" -OutputFile "Procesos.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\pslist64.exe /accepteula" -OutputFile "Procesos_x64.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\cprocess.exe /stext Procesosdeusuarios.txt" -OutputFile "Procesosdeusuarios.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\listdlls.exe /accepteula" -OutputFile "Procesosdependencias.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\openports.exe -path" -OutputFile "Mapa_agrupado_puertos_procesos.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\Handle.exe /accepteula" -OutputFile "Procesosmanejadores.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\promiscdetect.exe" -OutputFile "Adaptadorespromiscuos.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\urlprotocolview.exe /stext RedProtocolos.txt" -OutputFile "RedProtocolos.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\openedfilesview.exe /stext Ficherosabiertos.txt" -OutputFile "Ficherosabiertos.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psfile.exe /accepteula" -OutputFile "Ficheros_remotos_abiertos.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psfile64.exe /accepteula" -OutputFile "Ficheros_remotos_abiertos_x64.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\logonsessions.exe /accepteula" -OutputFile "Sesiones-activas.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\logonsessions64.exe /accepteula" -OutputFile "Sesiones-activas_x64.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psGetsid.exe" -OutputFile "Usuarios-sid.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psGetsid64.exe" -OutputFile "Usuarios-sid_x64.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\InsideClipboard.exe /stext" -OutputFile "Informacion_portapapeles.$outputFormat"

Write-Host "Script executed. Outputs saved in $outputFolder" -ForegroundColor Green

