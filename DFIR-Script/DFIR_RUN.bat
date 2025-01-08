@echo off
setlocal

:: Define output folder
set "outputFolder=%~dp0OUTPUT"

:: Create output folder if it doesn't exist
if not exist "%outputFolder%" (
    mkdir "%outputFolder%"
)

:: Debug: Output current directory and folder
echo Current directory: %~dp0
echo Output folder: %outputFolder%

:: 1. Run ipconfig /all
echo Running ipconfig /all...
ipconfig /all > "%outputFolder%\NetworkConfiguration.txt"
echo Saved ipconfig /all to %outputFolder%\NetworkConfiguration.txt

:: 2. Run ipconfig /displaydns
echo Running ipconfig /displaydns...
ipconfig /displaydns > "%outputFolder%\DNS_Queries.txt"
echo Saved ipconfig /displaydns to %outputFolder%\DNS_Queries.txt

:: 3. Run nbtstat -s
echo Running nbtstat -s...
nbtstat -s > "%outputFolder%\NetbiosSessions.txt"
echo Saved nbtstat -s to %outputFolder%\NetbiosSessions.txt

:: 4. Run nbtstat -c
echo Running nbtstat -c...
nbtstat -c > "%outputFolder%\NetbiosCache.txt"
echo Saved nbtstat -c to %outputFolder%\NetbiosCache.txt

:: 5. Run netstat -an and filter for listening and established
echo Running netstat -an...
netstat -an | findstr /i "listening established" > "%outputFolder%\ActiveConnections.txt"
echo Saved netstat -an filtered to %outputFolder%\ActiveConnections.txt

:: 6. Run netstat -anob
echo Running netstat -anob...
netstat -anob > "%outputFolder%\OpenPortsApplications.txt"
echo Saved netstat -anob to %outputFolder%\OpenPortsApplications.txt

:: 7. Run netstat -r
echo Running netstat -r...
netstat -r > "%outputFolder%\RoutingTable.txt"
echo Saved netstat -r to %outputFolder%\RoutingTable.txt

:: 8. Run netstat -ano
echo Running netstat -ano...
netstat -ano > "%outputFolder%\ActiveConnections.txt"
echo Saved netstat -ano to %outputFolder%\ActiveConnections.txt

:: 9. Run type hosts file
echo Running type C:\Windows\System32\drivers\etc\hosts...
type C:\Windows\System32\drivers\etc\hosts > "%outputFolder%\Hosts.txt"
echo Saved hosts file to %outputFolder%\Hosts.txt

:: 10. Run net file
echo Running net file...
net file > "%outputFolder%\FileTransferOverNetbios.txt"
echo Saved net file to %outputFolder%\FileTransferOverNetbios.txt

:: 11. Run arp -a
echo Running arp -a...
arp -a > "%outputFolder%\ArpCache.txt"
echo Saved arp -a to %outputFolder%\ArpCache.txt

:: 12. Run route PRINT
echo Running route PRINT...
route PRINT > "%outputFolder%\RoutingTable.txt"
echo Saved route PRINT to %outputFolder%\RoutingTable.txt

:: 13. Run net use
echo Running net use...
net use > "%outputFolder%\MappedDrives.txt"
echo Saved net use to %outputFolder%\MappedDrives.txt

:: 14. Run net share
echo Running net share...
net share > "%outputFolder%\SharedFolders.txt"
echo Saved net share to %outputFolder%\SharedFolders.txt

:: 15. Run net use (again)
echo Running net use...
net use > "%outputFolder%\SharedResources.txt"
echo Saved net use to %outputFolder%\SharedResources.txt

:: 16. Run nbtstat -n
echo Running nbtstat -n...
nbtstat -n > "%outputFolder%\SharedResourceUsers.txt"
echo Saved nbtstat -n to %outputFolder%\SharedResourceUsers.txt

:: 17. Run net USERS
echo Running net USERS...
net USERS > "%outputFolder%\LocalAndRemoteUsers.txt"
echo Saved net USERS to %outputFolder%\LocalAndRemoteUsers.txt

:: 18. Run net sessions
echo Running net sessions...
net sessions > "%outputFolder%\RemoteUsersIP.txt"
echo Saved net sessions to %outputFolder%\RemoteUsersIP.txt

:: 19. Run doskey /history
echo Running doskey /history...
doskey /history > "%outputFolder%\CMDHistory.txt"
echo Saved doskey /history to %outputFolder%\CMDHistory.txt

:: 20. Run Get-Service (PowerShell)
echo Running Get-Service (PowerShell)...
powershell Get-Service > "%outputFolder%\RunningServices.txt"
echo Saved Get-Service to %outputFolder%\RunningServices.txt

:: 21. Run Get-CimInstance (uptime) (PowerShell)
echo Running Get-CimInstance for uptime (PowerShell)...
powershell (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime > "%outputFolder%\Uptime.txt"
echo Saved uptime to %outputFolder%\Uptime.txt

:: 22. Run tasklist.exe
echo Running tasklist.exe...
tasklist.exe > "%outputFolder%\RunningProcesses.txt"
echo Saved tasklist to %outputFolder%\RunningProcesses.txt

:: 23. Run pslist.exe
echo Running pslist.exe...
"%~dp0pslist.exe" /accepteula > "%outputFolder%\Processes.txt"
echo Saved pslist to %outputFolder%\Processes.txt

:: 24. Run cprocess.exe
echo Running cprocess.exe...
"%~dp0cprocess.exe" /stext "%outputFolder%\UserProcesses.txt"
echo Saved cprocess to %outputFolder%\UserProcesses.txt

:: 25. Run pslist.exe with -t option
echo Running pslist.exe with -t option...
"%~dp0pslist.exe" -t /accepteula > "%outputFolder%\ProcessTree.txt"
"%~dp0pslist64.exe" -t /accepteula > "%outputFolder%\ProcessTree_x64.txt"
echo Saved pslist -t to %outputFolder%\ProcessTree.txt

:: 26. Run listdlls.exe
echo Running listdlls.exe...
"%~dp0listdlls.exe" /accepteula > "%outputFolder%\ProcessDependencies.txt"
echo Saved listdlls to %outputFolder%\ProcessDependencies.txt

:: 27. Run openports.exe
echo Running openports.exe...
"%~dp0openports.exe" -path > "%outputFolder%\GroupedPortsProcessMap.txt"
echo Saved openports to %outputFolder%\GroupedPortsProcessMap.txt

:: 28. Run Handle.exe
echo Running Handle.exe...
"%~dp0Handle.exe" /accepteula > "%outputFolder%\ProcessHandles.txt"
echo Saved Handle to %outputFolder%\ProcessHandles.txt

:: 29. Run promiscdetect.exe
echo Running promiscdetect.exe...
"%~dp0promiscdetect.exe" > "%outputFolder%\PromiscuousAdapters.txt"
echo Saved promiscdetect to %outputFolder%\PromiscuousAdapters.txt

:: 30. Run urlprotocolview.exe
echo Running urlprotocolview.exe...
"%~dp0urlprotocolview.exe" /stext "%outputFolder%\NetworkProtocols.txt"
echo Saved urlprotocolview to %outputFolder%\NetworkProtocols.txt

:: 31. Run openedfilesview.exe
echo Running openedfilesview.exe...
"%~dp0openedfilesview.exe" /stext "%outputFolder%\OpenedFiles.txt"
echo Saved openedfilesview to %outputFolder%\OpenedFiles.txt

:: 32. Run psfile.exe
echo Running psfile.exe...
"%~dp0psfile.exe" /accepteula > "%outputFolder%\RemoteOpenedFiles.txt"
"%~dp0psfile64.exe" /accepteula > "%outputFolder%\RemoteOpenedFiles_x64.txt"
echo Saved psfile to %outputFolder%\RemoteOpenedFiles.txt

:: 33. Run logonsessions.exe
echo Running logonsessions.exe...
"%~dp0logonsessions.exe" /accepteula > "%outputFolder%\ActiveSessions.txt"
"%~dp0logonsessions64.exe" /accepteula > "%outputFolder%\ActiveSessions_x64.txt"
echo Saved logonsessions to %outputFolder%\ActiveSessions.txt

:: 34. Run psGetsid.exe
echo Running psGetsid.exe...
"%~dp0psGetsid.exe" > "%outputFolder%\UsersSid.txt"
"%~dp0psGetsid64.exe" > "%outputFolder%\UsersSid_x64.txt"
echo Saved psGetsid to %outputFolder%\UsersSid.txt

:: 35. Run InsideClipboard.exe
echo Running InsideClipboard.exe...
"%~dp0InsideClipboard.exe" /stext "%outputFolder%\ClipboardInfo.txt"
echo Saved InsideClipboard to %outputFolder%\ClipboardInfo.txt

:: 36. Save PowerShell history
echo Running PowerShell history...
powershell Get-Content (Get-PSReadlineOption).HistorySavePath > "%outputFolder%\PowerShellHistory.txt"
echo Saved PowerShell history to %outputFolder%\PowerShellHistory.txt

:: Finished
echo Script executed. Outputs saved in %outputFolder%

endlocal
