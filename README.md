# DFIR Data Collection Script

A script designed for **Digital Forensics and Incident Response (DFIR)** to collect critical information from live Windows systems. This tool automates the execution of built-in and third-party utilities to gather data useful for forensic analysis and security incident investigation.

## Features

- Collects network configurations, active connections, and system data.
- Uses built-in Windows tools (`ipconfig`, `netstat`, `nbtstat`, etc.) and third-party tools (e.g., Sysinternals).
- Outputs data to a folder for easy access and review during post-incident investigations.
- Designed for quick deployment in incident response scenarios.

## Supported Tools

- **Built-in Commands**:
  - `ipconfig /all`, `netstat -an`, `nbtstat -s`, and others.
  
- **Third-Party Tools** (included in this repository):
  - Sysinternals tools (e.g., `pslist.exe`, `handle.exe`, `openports.exe`).
  - NirSoft utilities (e.g., `InsideClipboard.exe`, `urlprotocolview.exe`).

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dfir-network-tools.git

    Navigate to the script folder and execute the script in a Windows environment:

    You will find two scripts named:
        DFIR-RUN.bat
        DFIR-RUN.ps1

    If you want the data in .txt format or do not have execution permissions for scripts on the target machine, use the .bat script (note that some commands require elevated privileges to execute). If you want the data in .csv or .json format, you should execute the .ps1 script in a PowerShell terminal with elevated privileges.

    Keep in mind that the executables used in the script should be in the same directory from where these scripts are run.

    Check the generated output files (e.g., Configuracion_red.txt, Conexionesactivas.txt) for useful forensic data.

## License

This repository includes the script and tools for Digital Forensics and Incident Response purposes only. While the script is open-source, some third-party tools may be subject to their respective licenses.

    Script License: MIT License (or your preferred open-source license).
    Third-Party Tools License: Check individual tool documentation (e.g., Sysinternals License).

## Disclaimer

This tool is intended for use in incident response and digital forensics. It should only be used in compliance with applicable laws and regulations. Unauthorized use could violate privacy laws or be considered illegal activity.

## Contributing

If you would like to contribute to this project, please fork the repository, create a new branch, and submit a pull request with your changes. Contributions are welcome, especially improvements to the script or the addition of new tools!
Acknowledgements

    Microsoft Sysinternals - Tools for advanced system troubleshooting.
    NirSoft - Free utilities for system administrators and forensic investigators.

    Note: This script is meant to collect data for forensic investigations in Windows environments. Please ensure you have proper authorization to run this tool on any system.



# Script de Recolección de Datos para DFIR

Un script diseñado para **Digital Forensics and Incident Response (DFIR)**, que recolecta información crítica de sistemas Windows en vivo. Esta herramienta automatiza la ejecución de utilidades incorporadas y de terceros para recopilar datos útiles en el análisis forense e investigación de incidentes de seguridad.

## Características

- Recopila configuraciones de red, conexiones activas y datos del sistema.
- Utiliza herramientas incorporadas de Windows (`ipconfig`, `netstat`, `nbtstat`, etc.) y herramientas de terceros (por ejemplo, Sysinternals).
- Genera datos en una carpeta para facilitar su acceso y revisión durante las investigaciones posteriores al incidente.
- Diseñado para un despliegue rápido en escenarios de respuesta a incidentes.

## Herramientas Compatibles

- **Comandos Incorporados**:
  - `ipconfig /all`, `netstat -an`, `nbtstat -s`, entre otros.
  
- **Herramientas de Terceros** (incluidas en este repositorio):
  - Herramientas de Sysinternals (por ejemplo, `pslist.exe`, `handle.exe`, `openports.exe`).
  - Utilidades de NirSoft (por ejemplo, `InsideClipboard.exe`, `urlprotocolview.exe`).

## Uso

1. Clona este repositorio:
   ```bash
   git clone https://github.com/tuusuario/dfir-network-tools.git

    Navega a la carpeta del script y ejecuta el script en un entorno Windows:

    Aquí encontrarás dos scripts llamados:
    -  DFIR-RUN.bat
    -  DFIR-RUN.ps1
   
    Si queremos los datos en formato .txt o no tenemos permisos de ejecución de scripts en la máquina objetivo usaremos el .bat (a tener en cuenta que ciertos comandos requieren de privilegios elevados para ser ejecutados)
    Si queremos los datos en formato csv o json debemos ejecutar el script .ps1 en una terminal powershell con privilegios elevados.

    Ten encuenta que los ejecutables utilizados en el script deben estar en la misma ruta desde donde se ejecutan estos scripts.
    Revisa los archivos de salida generados (por ejemplo, Configuracion_red.txt, Conexionesactivas.txt) para obtener datos útiles en el análisis forense.

## Licencia

Este repositorio incluye el script y herramientas solo para Digital Forensics and Incident Response. Aunque el script es de código abierto, algunas herramientas de terceros pueden estar sujetas a sus respectivas licencias.

    Licencia del Script: Licencia MIT (o la licencia de código abierto que prefieras).
    Licencia de Herramientas de Terceros: Consulta la documentación de cada herramienta individual (por ejemplo, Licencia de Sysinternals).

## Descargo de Responsabilidad

Esta herramienta está destinada para ser utilizada en respuesta a incidentes y forense digital. Debe ser usada únicamente cumpliendo con las leyes y regulaciones aplicables. El uso no autorizado podría violar leyes de privacidad o ser considerado una actividad ilegal.

## Contribuciones

Si deseas contribuir a este proyecto, por favor forkea el repositorio, crea una nueva rama y envía un pull request con tus cambios. ¡Las contribuciones son bienvenidas, especialmente mejoras al script o la adición de nuevas herramientas!
Agradecimientos

    Microsoft Sysinternals - Herramientas para la solución avanzada de problemas del sistema.
    NirSoft - Utilidades gratuitas para administradores de sistemas e investigadores forenses.

    Nota: Este script está destinado a recolectar datos para investigaciones forenses en entornos Windows. Asegúrate de tener la autorización adecuada para ejecutar esta herramienta en cualquier sistema.
