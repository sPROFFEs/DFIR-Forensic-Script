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
ipconfig /all > "%outputFolder%\Configuracion_red.txt"
echo Saved ipconfig /all to %outputFolder%\Configuracion_red.txt

:: 2. Run ipconfig /displaydns
echo Running ipconfig /displaydns...
ipconfig /displaydns > "%outputFolder%\DNS_consultas.txt"
echo Saved ipconfig /displaydns to %outputFolder%\DNS_consultas.txt

:: 3. Run nbtstat -s
echo Running nbtstat -s...
nbtstat -s > "%outputFolder%\Sesionnetbios.txt"
echo Saved nbtstat -s to %outputFolder%\Sesionnetbios.txt

:: 4. Run nbtstat -c
echo Running nbtstat -c...
nbtstat -c > "%outputFolder%\Cachenetbios.txt"
echo Saved nbtstat -c to %outputFolder%\Cachenetbios.txt

:: 5. Run netstat -an and filter for listening and established
echo Running netstat -an...
netstat -an | findstr /i "listening established" > "%outputFolder%\Conexionesactivas.txt"
echo Saved netstat -an filtered to %outputFolder%\Conexionesactivas.txt

:: 6. Run netstat -anob
echo Running netstat -anob...
netstat -anob > "%outputFolder%\AplicacionesPuertosAbiertos.txt"
echo Saved netstat -anob to %outputFolder%\AplicacionesPuertosAbiertos.txt

:: 7. Run netstat -r
echo Running netstat -r...
netstat -r > "%outputFolder%\Tablarutas.txt"
echo Saved netstat -r to %outputFolder%\Tablarutas.txt

:: 8. Run netstat -ano
echo Running netstat -ano...
netstat -ano > "%outputFolder%\Conexionesactivas.txt"
echo Saved netstat -ano to %outputFolder%\Conexionesactivas.txt

:: 9. Run type hosts file
echo Running type C:\Windows\System32\drivers\etc\hosts...
type C:\Windows\System32\drivers\etc\hosts > "%outputFolder%\Hosts.txt"
echo Saved hosts file to %outputFolder%\Hosts.txt

:: 10. Run net file
echo Running net file...
net file > "%outputFolder%\transferencia-ficheros-sobre-netbios.txt"
echo Saved net file to %outputFolder%\transferencia-ficheros-sobre-netbios.txt

:: 11. Run arp -a
echo Running arp -a...
arp -a > "%outputFolder%\arp-cache.txt"
echo Saved arp -a to %outputFolder%\arp-cache.txt

:: 12. Run route PRINT
echo Running route PRINT...
route PRINT > "%outputFolder%\TablaRutas.txt"
echo Saved route PRINT to %outputFolder%\TablaRutas.txt

:: 13. Run net use
echo Running net use...
net use > "%outputFolder%\UnidadesMapeadas.txt"
echo Saved net use to %outputFolder%\UnidadesMapeadas.txt

:: 14. Run net share
echo Running net share...
net share > "%outputFolder%\CarpetasCompartidas.txt"
echo Saved net share to %outputFolder%\CarpetasCompartidas.txt

:: 15. Run net use (again)
echo Running net use...
net use > "%outputFolder%\recursos_compartidos.txt"
echo Saved net use to %outputFolder%\recursos_compartidos.txt

:: 16. Run nbtstat -n
echo Running nbtstat -n...
nbtstat -n > "%outputFolder%\usuarios-recurso-compartidos.txt"
echo Saved nbtstat -n to %outputFolder%\usuarios-recurso-compartidos.txt

:: 17. Run net USERS
echo Running net USERS...
net USERS > "%outputFolder%\Usuarios-locales-y-remotos.txt"
echo Saved net USERS to %outputFolder%\Usuarios-locales-y-remotos.txt

:: 18. Run net sessions
echo Running net sessions...
net sessions > "%outputFolder%\Usuarios-remotos-ip.txt"
echo Saved net sessions to %outputFolder%\Usuarios-remotos-ip.txt

:: 19. Run doskey /history
echo Running doskey /history...
doskey /history > "%outputFolder%\HistoricoCMD.txt"
echo Saved doskey /history to %outputFolder%\HistoricoCMD.txt

:: 20. Run Get-Service (PowerShell)
echo Running Get-Service (PowerShell)...
powershell Get-Service > "%outputFolder%\servicios-ejecucion.txt"
echo Saved Get-Service to %outputFolder%\servicios-ejecucion.txt

:: 21. Run Get-CimInstance (uptime) (PowerShell)
echo Running Get-CimInstance for uptime (PowerShell)...
powershell (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime > "%outputFolder%\Tiempoencendido.txt"
echo Saved uptime to %outputFolder%\Tiempoencendido.txt

:: 22. Run tasklist.exe
echo Running tasklist.exe...
tasklist.exe > "%outputFolder%\Procesosenuso.txt"
echo Saved tasklist to %outputFolder%\Procesosenuso.txt

:: 23. Run pslist.exe
echo Running pslist.exe...
"%~dp0pslist.exe" /accepteula > "%outputFolder%\Procesos.txt"
echo Saved pslist to %outputFolder%\Procesos.txt

:: 24. Run cprocess.exe
echo Running cprocess.exe...
"%~dp0cprocess.exe" /stext "%outputFolder%\Procesosdeusuarios.txt"
echo Saved cprocess to %outputFolder%\Procesosdeusuarios.txt

:: 25. Run pslist.exe with -t option
echo Running pslist.exe with -t option...
"%~dp0pslist.exe" -t /accepteula > "%outputFolder%\procesosarbol.txt"
"%~dp0pslist64.exe" -t /accepteula > "%outputFolder%\procesosarbol_x64.txt"
echo Saved pslist -t to %outputFolder%\procesosarbol.txt

:: 26. Run listdlls.exe
echo Running listdlls.exe...
"%~dp0listdlls.exe" /accepteula > "%outputFolder%\Procesosdependencias.txt"
echo Saved listdlls to %outputFolder%\Procesosdependencias.txt

:: 27. Run openports.exe
echo Running openports.exe...
"%~dp0openports.exe" -path > "%outputFolder%\Mapa_agrupado_puertos_procesos.txt"
echo Saved openports to %outputFolder%\Mapa_agrupado_puertos_procesos.txt

:: 28. Run Handle.exe
echo Running Handle.exe...
"%~dp0Handle.exe" /accepteula > "%outputFolder%\Procesosmanejadores.txt"
echo Saved Handle to %outputFolder%\Procesosmanejadores.txt

:: 29. Run promiscdetect.exe
echo Running promiscdetect.exe...
"%~dp0promiscdetect.exe" > "%outputFolder%\Adaptadorespromiscuos.txt"
echo Saved promiscdetect to %outputFolder%\Adaptadorespromiscuos.txt

:: 30. Run urlprotocolview.exe
echo Running urlprotocolview.exe...
"%~dp0urlprotocolview.exe" /stext "%outputFolder%\RedProtocolos.txt"
echo Saved urlprotocolview to %outputFolder%\RedProtocolos.txt

:: 31. Run openedfilesview.exe
echo Running openedfilesview.exe...
"%~dp0openedfilesview.exe" /stext "%outputFolder%\Ficherosabiertos.txt"
echo Saved openedfilesview to %outputFolder%\Ficherosabiertos.txt

:: 32. Run psfile.exe
echo Running psfile.exe...
"%~dp0psfile.exe" /accepteula > "%outputFolder%\Ficheros_remotos_abiertos.txt"
"%~dp0psfile64.exe" /accepteula > "%outputFolder%\Ficheros_remotos_abiertos_x64.txt"
echo Saved psfile to %outputFolder%\Ficheros_remotos_abiertos.txt

:: 33. Run logonsessions.exe
echo Running logonsessions.exe...
"%~dp0logonsessions.exe" /accepteula > "%outputFolder%\Sesiones-activas.txt"
"%~dp0logonsessions64.exe" /accepteula > "%outputFolder%\Sesiones-activas_x64.txt"
echo Saved logonsessions to %outputFolder%\Sesiones-activas.txt

:: 34. Run psGetsid.exe
echo Running psGetsid.exe...
"%~dp0psGetsid.exe" > "%outputFolder%\Usuarios-sid.txt"
"%~dp0psGetsid64.exe" > "%outputFolder%\Usuarios-sid_x64.txt"
echo Saved psGetsid to %outputFolder%\Usuarios-sid.txt

:: 35. Run InsideClipboard.exe
echo Running InsideClipboard.exe...
"%~dp0InsideClipboard.exe" /stext "%outputFolder%\Informacion_portapapeles.txt"
echo Saved InsideClipboard to %outputFolder%\Informacion_portapapeles.txt

:: Finished
echo Script executed. Outputs saved in %outputFolder%

endlocal
