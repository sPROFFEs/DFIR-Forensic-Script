# Function to create a more structured output format
function Format-CommandOutput {
    param (
        [string]$CommandOutput,
        [string]$CommandName
    )
    
    $outputLines = @($CommandOutput -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
    $result = [ordered]@{
        CommandName = $CommandName
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Data = [System.Collections.ArrayList]@()
    }
    
    $currentSection = ""
    $headers = @()
    
    for ($i = 0; $i -lt $outputLines.Count; $i++) {
        $line = $outputLines[$i]
        
        # Skip separator lines
        if ($line -match "^[-=]+$") { continue }
        
        # Check if line is a header (key-value pair)
        if ($line -match '^([^:]+):\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            [void]$result.Data.Add([PSCustomObject]@{
                Section = $currentSection
                Property = $key
                Value = if ($value -eq "") { "N/A" } else { $value }
            })
        }
        # Handle table-like output
        elseif ($line -match '^\s*\S+\s+\S+') {
            $parts = @($line -split '\s+' | Where-Object { $_ -ne "" })
            
            # If this looks like a header row
            if ($line -match '(IP Address|Protocol|Local|Remote|Status|PID|Process)' -or 
                $parts[0] -match '^[A-Za-z]+$') {
                $headers = $parts
                $currentSection = "Table"
                continue
            }
            
            # If we have headers, create an object with named properties
            if ($headers.Count -gt 0 -and $parts.Count -le $headers.Count) {
                $obj = [ordered]@{
                    Section = $currentSection
                }
                
                for ($j = 0; $j -lt $parts.Count; $j++) {
                    $headerName = if ($j -lt $headers.Count) { $headers[$j] } else { "Column$($j + 1)" }
                    $obj[$headerName] = $parts[$j]
                }
                
                [void]$result.Data.Add([PSCustomObject]$obj)
            }
            # Otherwise just add the raw data
            else {
                [void]$result.Data.Add([PSCustomObject]@{
                    Section = $currentSection
                    RawData = $line
                })
            }
        }
        # Handle single-line output
        elseif ($line.Trim()) {
            [void]$result.Data.Add([PSCustomObject]@{
                Section = $currentSection
                RawData = $line.Trim()
            })
        }
    }
    
    return $result
}

function Run-And-Export {
    param (
        [string]$Command,
        [string]$OutputFile,
        [string]$CommandName
    )
    
    try {
        Write-Host "Executing command: $CommandName" -ForegroundColor Cyan
        
        # Execute command and capture output
        $rawOutput = if ($Command -is [scriptblock]) {
            & $Command 2>&1 | Out-String
        } else {
            Invoke-Expression $Command 2>&1 | Out-String
        }
        
        # Check if the command produced any output
        if ([string]::IsNullOrWhiteSpace($rawOutput)) {
            Write-Host "Command produced no output" -ForegroundColor Yellow
            $rawOutput = "No output"
        }
        
        # Format the output
        $formattedOutput = Format-CommandOutput -CommandOutput $rawOutput -CommandName $CommandName
        
        $outputFilePath = Join-Path $outputFolder $OutputFile
        
        if ($outputFormat -eq "json") {
            $jsonFormatted = $formattedOutput | ConvertTo-Json -Depth 10
            $jsonFormatted | Out-File -FilePath $outputFilePath -Encoding utf8
        }
        elseif ($outputFormat -eq "csv") {
            # Export directly to CSV if the Data property contains objects
            if ($formattedOutput.Data.Count -gt 0) {
                $formattedOutput.Data | Select-Object -Property * -ExcludeProperty PSObject | Export-Csv -Path $outputFilePath -NoTypeInformation -Encoding UTF8
            }
            else {
                # Fallback for simple output
                [PSCustomObject]@{
                    CommandName = $formattedOutput.CommandName
                    Timestamp = $formattedOutput.Timestamp
                    Output = $rawOutput
                } | Export-Csv -Path $outputFilePath -NoTypeInformation -Encoding UTF8
            }
        }
        
        Write-Host "Output saved to: $outputFilePath" -ForegroundColor Green
    }
    catch {
        Write-Host "Error executing command $CommandName : $($_.Exception.Message)" -ForegroundColor Red
        $errorLog = Join-Path $outputFolder "error_log.txt"
        "$(Get-Date) - Error in $CommandName : $($_.Exception.Message)`nStackTrace: $($_.ScriptStackTrace)" | Out-File -Append -FilePath $errorLog
    }
}

# Main script execution
$rootFolder = Read-Host "Enter the name of the root folder (e.g., 'DFIR_Analysis')"
$computerName = $env:COMPUTERNAME
$currentDateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputFolderName = "${computerName}_${currentDateTime}"
$outputFolder = Join-Path $PSScriptRoot $rootFolder
$outputFolder = Join-Path $outputFolder "OUTPUT"
$outputFolder = Join-Path $outputFolder $outputFolderName

if (-not (Test-Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory -Force | Out-Null
}

Write-Host "Output folder created at: $outputFolder" -ForegroundColor Green

$outputFormat = Read-Host "Enter desired output format (json (recommended) / csv)"
if ($outputFormat -notin @("json", "csv")) {
    Write-Host "Invalid format. Defaulting to JSON." -ForegroundColor Yellow
    $outputFormat = "json"
}

# Define commands to run
$commands = [ordered]@{
    # Network Configuration Commands
    "NetworkConfiguration" = "ipconfig /all"
    "DNSQueries" = "ipconfig /displaydns"
    "NetbiosSession" = "nbtstat -s"
    "NetbiosCache" = "nbtstat -c"
    "ActiveConnections1" = "netstat -an | findstr /i 'listening established'"
    "ActiveConnections2" = "netstat -ano"
    "OpenPortApplications" = "netstat -anob"
    "RouteTable1" = "netstat -r"
    "RouteTable2" = "route PRINT"
    "Hosts" = "type C:\Windows\System32\drivers\etc\hosts"
    "NetbiosFileTransfer" = "net file"
    "ArpCache" = "arp -a"
    
    # Share and Resource Commands
    "MappedDrives" = "net use"
    "SharedFolders" = "net share"
    "SharedResources" = "net use"
    "SharedResourceUsers" = "nbtstat -n"
    
    # User and Session Commands
    "LocalAndRemoteUsers" = "net USERS"
    "RemoteUsersAndIP" = "net sessions"
    
    # History and Services
    "CmdHistory" = "doskey /history"
    "RunningServices" = "Get-Service"
    
    # System Information
    "Uptime" = {
        $uptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        $uptime = (Get-Date) - $uptime
        $uptime | Out-String
    }
    
    # Process Information
    "RunningProcesses" = "tasklist.exe"
    
    # Sysinternals and External Tools
    "Processes" = "$PSScriptRoot\pslist.exe /accepteula"
    "Processes_x64" = "$PSScriptRoot\pslist64.exe /accepteula"
    "UserProcesses" = "$PSScriptRoot\cprocess.exe /stext UserProcesses.txt"
    "ProcessDependencies" = "$PSScriptRoot\listdlls.exe /accepteula"
    "GroupedPortsProcessMap" = "$PSScriptRoot\openports.exe -path"
    "HandleProcesses" = "$PSScriptRoot\Handle.exe /accepteula"
    "PromiscuousAdapters" = "$PSScriptRoot\promiscdetect.exe"
    "NetworkProtocols" = "$PSScriptRoot\urlprotocolview.exe /stext NetworkProtocols.txt"
    "OpenedFiles" = "$PSScriptRoot\openedfilesview.exe /stext OpenedFiles.txt"
    "RemoteOpenedFiles" = "$PSScriptRoot\psfile.exe /accepteula"
    "RemoteOpenedFiles_x64" = "$PSScriptRoot\psfile64.exe /accepteula"
    "ActiveSessions" = "$PSScriptRoot\logonsessions.exe /accepteula"
    "ActiveSessions_x64" = "$PSScriptRoot\logonsessions64.exe /accepteula"
    "UserSID" = "$PSScriptRoot\psGetsid.exe"
    "UserSID_x64" = "$PSScriptRoot\psGetsid64.exe"
    "ClipboardInfo" = "$PSScriptRoot\InsideClipboard.exe /stext ClipboardInfo.txt"
}

# Execute commands
foreach ($command in $commands.GetEnumerator()) {
    Run-And-Export -Command $command.Value -OutputFile "$($command.Key).$outputFormat" -CommandName $command.Key
}

# Process all the generated .txt files from /stext commands
Start-Sleep -Seconds 3
$stextFiles = Get-ChildItem -Path $PSScriptRoot -Filter "*.txt"
foreach ($file in $stextFiles) {
    if ($file.Name -match "(UserProcesses|NetworkProtocols|OpenedFiles|ClipboardInfo)\.txt") {
        $destination = Join-Path $outputFolder $file.Name
        Write-Host "Moving file: $($file.FullName) to $destination"
        Move-Item -Path $file.FullName -Destination $destination -Force
        
        # Convert .txt to desired format
        $newFileName = [System.IO.Path]::ChangeExtension($file.Name, $outputFormat)
        Run-And-Export -Command "Get-Content '$destination'" -OutputFile $newFileName -CommandName $file.BaseName
        
        # Remove original .txt file
        Remove-Item -Path $destination -Force
    }
}

# Handle PowerShell history
$historyFilePath = (Get-PSReadlineOption).HistorySavePath
if (Test-Path $historyFilePath) {
    Run-And-Export -Command "Get-Content '$historyFilePath'" -OutputFile "PowerShell_History.$outputFormat" -CommandName "PowerShellHistory"
}

# Create summary report
$summary = [ordered]@{
    ComputerName = $computerName
    CollectionDate = $currentDateTime
    OutputFormat = $outputFormat
    CommandsExecuted = @($commands.Keys)
    OutputLocation = $outputFolder
    ErrorLogLocation = Join-Path $outputFolder "error_log.txt"
    ExternalToolsUsed = @($commands.Values | Where-Object { $_ -like "*$PSScriptRoot*" } | ForEach-Object { ($_ -split '\\')[0] })
}

$summary | ConvertTo-Json | Out-File -FilePath (Join-Path $outputFolder "collection_summary.$outputFormat")

Write-Host "`nDFIR collection completed successfully!" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "- Computer Name: $computerName"
Write-Host "- Collection Date: $currentDateTime"
Write-Host "- Output Format: $outputFormat"
Write-Host "- Output Location: $outputFolder"
Write-Host "- Commands Executed: $($commands.Count)"
Write-Host "- Check error_log.txt for any issues encountered during collection"
