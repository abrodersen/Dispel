# Dispel
Dispel is a program designed to eleminate annoying HTTP redirects caused by SafeConnect, a network access control system. Dispel is meant to run in the background, detecting redirects before they affect you and taking corrective action.
# Platforms
## Windows
-------
The Windows version of Dispel is written in PowerShell script. In order to run it, the PowerShell Execution Policy must be set to Unrestricted.

1. Open a PowerShell console.
    * On Windows 7, click Start > Accessories > Windows PowerShell.
	* Right-click on the Windows PowerShell program and click Run as administrator.
2. Run the following command to change the Execution Policy.
   ```
   Set-ExecutionPolicy RemoteSigned
   ```
	
Once the PowerShell Execution Policy has been changed, Dispel can be started by right-clicking on the script file and clicking Run with PowerShell.