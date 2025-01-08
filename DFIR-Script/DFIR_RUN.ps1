$rootFolder = Read-Host "Enter the name of the root folder (e.g., 'DFIR_Analysis')"

$computerName = $env:COMPUTERNAME
$currentDateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$outputFolderName = "${computerName}_${currentDateTime}"


$outputFolder = Join-Path $PSScriptRoot $rootFolder        
$outputFolder = Join-Path $outputFolder "OUTPUT"          
$outputFolder = Join-Path $outputFolder $outputFolderName 

if (-not (Test-Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory | Out-Null
}

Write-Host "La carpeta de salida se ha creado en: $outputFolder" -ForegroundColor Green

$outputFormat = Read-Host "Enter desired output format (json (recommended) / csv (less precise info arrangement))"
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

        $output = $output -replace "`r`n", "`n"  
        $output = $output.Trim() 

        $formattedOutput = @{}
        $lineCounter = 1  
        $csvOutput = @()

        $output.Split("`n") | ForEach-Object {
            $line = $_.Trim()

            if ($line -eq "" -or $line -match "^={3,}$") {
                return
            }

            if ($line -match '^(\S[\w\s-]+):\s*(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()

                if ($value -eq "") {
                    $value = "null"
                }

                $formattedOutput[$key] = $value

                $csvOutput += [PSCustomObject]@{ "Key" = $key; "Value" = $value }
            } else {
                $formattedOutput["Line$lineCounter"] = $line

                $csvOutput += [PSCustomObject]@{ "Line" = $line }
                $lineCounter++
            }
        }

        $outputFilePath = Join-Path $outputFolder $OutputFile
        Write-Host "Saving output to: $outputFilePath"

        if ($outputFormat -eq "json") {
            $jsonFormatted = $formattedOutput | ConvertTo-Json -Depth 10
            $jsonFormatted | Out-File -FilePath $outputFilePath -Encoding utf8
        }

        if ($outputFormat -eq "csv") {
            $csvOutput | Export-Csv -Path $outputFilePath -NoTypeInformation -Encoding UTF8
        }
    } catch {
        Write-Host "Error executing the command: $($_.Exception.Message)" -ForegroundColor Red
    }
}


# Run the desired commands and save the results
Run-And-Export -Command "ipconfig /all" -OutputFile "NetworkConfiguration.$outputFormat"
Run-And-Export -Command "ipconfig /displaydns" -OutputFile "DNSQueries.$outputFormat"
Run-And-Export -Command "nbtstat -s" -OutputFile "NetbiosSession.$outputFormat"
Run-And-Export -Command "nbtstat -c" -OutputFile "NetbiosCache.$outputFormat"
Run-And-Export -Command "netstat -an | findstr /i 'listening established'" -OutputFile "ActiveConnections.$outputFormat"
Run-And-Export -Command "netstat -anob" -OutputFile "OpenPortApplications.$outputFormat"
Run-And-Export -Command "netstat -r" -OutputFile "RouteTable.$outputFormat"
Run-And-Export -Command "netstat -ano" -OutputFile "ActiveConnections.$outputFormat"
Run-And-Export -Command "type C:\\Windows\\System32\\drivers\\etc\\hosts" -OutputFile "Hosts.$outputFormat"
Run-And-Export -Command "net file" -OutputFile "NetbiosFileTransfer.$outputFormat"
Run-And-Export -Command "arp -a" -OutputFile "ArpCache.$outputFormat"
Run-And-Export -Command "route PRINT" -OutputFile "RouteTable.$outputFormat"
Run-And-Export -Command "net use" -OutputFile "MappedDrives.$outputFormat"
Run-And-Export -Command "net share" -OutputFile "SharedFolders.$outputFormat"
Run-And-Export -Command "net use" -OutputFile "SharedResources.$outputFormat"
Run-And-Export -Command "nbtstat -n" -OutputFile "SharedResourceUsers.$outputFormat"
Run-And-Export -Command "net USERS" -OutputFile "LocalAndRemoteUsers.$outputFormat"
Run-And-Export -Command "net sessions" -OutputFile "RemoteUsersAndIP.$outputFormat"
Run-And-Export -Command "doskey /history" -OutputFile "CmdHistory.$outputFormat"
Run-And-Export -Command "Get-Service" -OutputFile "RunningServices.$outputFormat"
Run-And-Export -Command {
    $uptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $uptime = (Get-Date) - $uptime
    $uptime | Out-String
} -OutputFile "Uptime.$outputFormat"
Run-And-Export -Command "tasklist.exe" -OutputFile "RunningProcesses.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\pslist.exe /accepteula" -OutputFile "Processes.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\pslist64.exe /accepteula" -OutputFile "Processes_x64.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\cprocess.exe /stext UserProcesses.txt" -OutputFile "UserProcesses.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\listdlls.exe /accepteula" -OutputFile "ProcessDependencies.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\openports.exe -path" -OutputFile "GroupedPortsProcessMap.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\Handle.exe /accepteula" -OutputFile "HandleProcesses.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\promiscdetect.exe" -OutputFile "PromiscuousAdapters.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\urlprotocolview.exe /stext NetworkProtocols.txt" -OutputFile "NetworkProtocols.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\openedfilesview.exe /stext OpenedFiles.txt" -OutputFile "OpenedFiles.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psfile.exe /accepteula" -OutputFile "RemoteOpenedFiles.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psfile64.exe /accepteula" -OutputFile "RemoteOpenedFiles_x64.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\logonsessions.exe /accepteula" -OutputFile "ActiveSessions.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\logonsessions64.exe /accepteula" -OutputFile "ActiveSessions_x64.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psGetsid.exe" -OutputFile "UserSID.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\psGetsid64.exe" -OutputFile "UserSID_x64.$outputFormat"
Run-And-Export -Command "$PSScriptRoot\\InsideClipboard.exe /stext ClipboardInfo.txt" -OutputFile "ClipboardInfo.$outputFormat"

Start-Sleep -Seconds 3

# Move all files generated by commands with '/stext' to the OUTPUT folder
$stextFiles = Get-ChildItem -Path $PSScriptRoot -Filter "*.txt"
foreach ($file in $stextFiles) {
    $destination = Join-Path $outputFolder $file.Name
    Write-Host "Moving file: $($file.FullName) to $destination"
    Move-Item -Path $file.FullName -Destination $destination
}

# Process all the moved .txt files to convert them to JSON or CSV
$txtFiles = Get-ChildItem -Path $outputFolder -Filter "*.txt"
foreach ($txtFile in $txtFiles) {
    Write-Host "Processing file: $($txtFile.Name)"
    
    # Determine the new file name with the correct extension based on user selection
    $newFileName = [System.IO.Path]::ChangeExtension($txtFile.Name, $outputFormat)

    # Call the Run-And-Export function with the new file name and desired output format
    Run-And-Export -Command "Get-Content '$($txtFile.FullName)'" -OutputFile $newFileName

    # Delete the original .txt file after conversion to avoid confusion
    Remove-Item -Path $txtFile.FullName
}

# Get PowerShell history and export it
$historyFilePath = (Get-PSReadlineOption).HistorySavePath

# Check if the history file exists and export its content
if (Test-Path $historyFilePath) {
    Run-And-Export -Command "Get-Content '$historyFilePath'" -OutputFile "PowerShell_History.$outputFormat"
} else {
    Write-Host "PowerShell history file not found at $historyFilePath" -ForegroundColor Red
}

Write-Host "Script executed. Outputs saved in $outputFolder" -ForegroundColor Green
