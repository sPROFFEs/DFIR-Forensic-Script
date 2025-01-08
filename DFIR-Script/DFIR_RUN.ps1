$outputFolder = Join-Path $PSScriptRoot "OUTPUT"

# Create the directory if it doesn't exist
if (-not (Test-Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory | Out-Null
}

# Prompt for output format (json/csv)
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
        # Execute the command and capture the output
        $output = Invoke-Expression $Command | Out-String

        # Clean up the output from extra characters
        $output = $output -replace "`r`n", "`n"  # Use only line breaks
        $output = $output.Trim() # Remove excessive spaces

        # Process the output line by line
        $formattedOutput = @{}
        $lineCounter = 1  # Counter for non-key:value lines
        $csvOutput = @()

        $output.Split("`n") | ForEach-Object {
            $line = $_.Trim()

            # If the line has a key:value format, process it
            if ($line -match '^(\S[\w\s-]+):\s*(\S.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()

                # Add to the final object for JSON
                $formattedOutput[$key] = $value

                # Also add the key-value to the CSV, as a row
                $csvOutput += [PSCustomObject]@{ $key = $value }
            } else {
                # If it's not a key:value line, create a unique key for each line
                $formattedOutput["Line$lineCounter"] = $line

                # For CSV, create a row with the line as "LineN"
                $csvOutput += [PSCustomObject]@{ Line = $line }
                $lineCounter++
            }
        }

        # Save the appropriate format
        $outputFilePath = Join-Path $outputFolder $OutputFile
        Write-Host "Saving output to: $outputFilePath"

        # If the output is JSON
        if ($outputFormat -eq "json") {
            # Convert the object to JSON with indentation
            $jsonFormatted = $formattedOutput | ConvertTo-Json -Depth 10
            $jsonFormatted | Out-File -FilePath $outputFilePath -Encoding utf8
        }

        # If the output is CSV
        if ($outputFormat -eq "csv") {
            # Export to CSV
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
Run-And-Export -Command "$PSScriptRoot\\InsideClipboard.exe /stext" -OutputFile "ClipboardInfo.$outputFormat"

# Get PowerShell history and export it
$historyFilePath = (Get-PSReadlineOption).HistorySavePath

# Check if the history file exists and export its content
if (Test-Path $historyFilePath) {
    Run-And-Export -Command "Get-Content '$historyFilePath'" -OutputFile "PowerShell_History.$outputFormat"
} else {
    Write-Host "PowerShell history file not found at $historyFilePath" -ForegroundColor Red
}

Write-Host "Script executed. Outputs saved in $outputFolder" -ForegroundColor Green


