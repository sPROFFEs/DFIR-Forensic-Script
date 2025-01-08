# DFIR Data Collection Script

A script designed for **Digital Forensics and Incident Response (DFIR)** to collect critical information from live Windows systems. This tool automates the execution of built-in and third-party utilities to gather data useful for forensic analysis and security incident investigation.

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://travis-ci.org/yourusername/dfir-network-tools) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

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

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dfir-network-tools.git
   ```
2. Navigate to the script folder.
3. Ensure all required executables are in the same directory.

## Usage

**Note** If you're going to use the script in PowerShell, make sure the PowerShell script execution policy is set up correctly.
  ```
 Set-ExecutionPolicy Unrestricted
  ```

You will find two scripts named:
- **DFIR-RUN.bat**: Use this if you want the data in .txt format or do not have execution permissions for scripts on the target machine.
- **DFIR-RUN.ps1**: Use this script in a PowerShell terminal with elevated privileges for .csv or .json format.

Check the generated output files (e.g., Configuracion_red.txt, Conexionesactivas.txt) for useful forensic data.

## License

This repository includes the script and tools for Digital Forensics and Incident Response purposes only. While the script is open-source, some third-party tools may be subject to their respective licenses.

    Script License: MIT License (or your preferred open-source license).
    Third-Party Tools License: Check individual tool documentation (e.g., Sysinternals License).

## Disclaimer

This tool is intended for use in incident response and digital forensics. It should only be used in compliance with applicable laws and regulations. Unauthorized use could violate privacy laws or be considered illegal activity.

## Contributing

If you would like to contribute to this project, please fork the repository, create a new branch, and submit a pull request with your changes. Contributions are welcome, especially improvements to the script or the addition of new tools!

## Acknowledgements

    Microsoft Sysinternals - Tools for advanced system troubleshooting.
    NirSoft - Free utilities for system administrators and forensic investigators.

## Support

For support or to report issues, please open an issue on this repository or contact the project maintainers.
