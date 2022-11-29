<#
.SYNOPSIS
  Synopsis of script
.DESCRIPTION
  Desctription of script
.PARAMETER None
  None
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        #.#
  Author:         <Name>     
  Creation Date:  dd/mm/yy
  Purpose/Change: Initial Script
.LINK
  None
.EXAMPLE
  ^ . Invoke-PSTemplate.ps1
  To import standard common Functions script as an include
.EXAMPLE
  ^ .\<scriptname>.ps1
  description of what the example does  
#>

#requires -version 4
#region ------------------------------------------------------[Script Parameters]--------------------------------------------------

Param (
  #Script parameters go here
)

#endregion
#region ------------------------------------------------------[Initialisations]----------------------------------------------------

#& Global Error Action
$ErrorActionPreference = 'SilentlyContinue'

#& Module Imports
#Import-Module ActiveDirectory

#& Includes - Scripts & Modules
. .\Get-CommonFunctions.ps1                          # Include Common Functions

#endregion
#region -------------------------------------------------------[Declarations]------------------------------------------------------

# Script sourced variables for General settings and Registry Operations
$Script:Date        = Get-Date -Format yyyy-MM-dd                                   # Date format in yyyy-mm-dd
$Script:Now         = ''                                                            # script sourced veriable for Get-Now function
$Script:dest        = $PSScriptRoot                                                 # Destination path
$Script:LogDir      = $PSScriptRoot                                                 # Logdir for Clear-TransLogs function for $PSScript Root
$Script:LogFile     = $Script:LogDir + $Script:Date + "_" + $env:USERNAME + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:File        = ''                                                            # File var for Get-FilePicker Function
$Script:ScriptName  = ''                                                            # Script Name used in the Open Dialogue
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:GUID        = '00000000-0000-0000-0000-000000000000'                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
$Script:Version     = '0.0'                                                         # Script Version Number
$Script:Client      = ''                                                            # Set Client Name - Used in Registry Operations
$Script:WHO         = whoami                                                        # Collect WhoAmI
$Script:Desc        = ""                                                            # Description displayed in Get-ScriptInfo function
$Script:Desc2       = ""                                                            # Description2 displayed in Get-ScriptInfo function
$Script:PSArchitecture = ''                                                         # Place holder for x86 / x64 bit detection

#^ File Picker Setup
$Script:FPDir       = '$PSScriptRoot'                                               # File Picker Initial Directory
$Script:FileTypes   = "Text files (*.txt)|*.txt|CSV File (*.csv)|*.csv|All files (*.*)|*.*" # File types to be listed in file picker
$Script:FileIndex   = "2"                                                           # What file type to set as default in file picker (based on above order)

#endregion
#region --------------------------------------------------------[Hash Tables]------------------------------------------------------

#endregion
#region -------------------------------------------------------[Functions]---------------------------------------------------------

#endregion
#region ------------------------------------------------------------[Classes]-------------------------------------------------------------

#endregion
#region -----------------------------------------------------------[Execution]------------------------------------------------------------
<#
? ---------------------------------------------------------- [NOTES:] -------------------------------------------------------------
& Best veiwed and edited with Microsoft Visual Studio Code with colorful comments extension
^ Transcription logging formatting use Get-Now before write-host to return current timestamp into $Scipt:Now variable
  Write-Host "$Script:Now [INFORMATION] Information Message"
  Write-Host "$Script:Now [INFORMATION] Highlighted Information Message" @chighlight
  Write-Host "$Script:Now [WARNING] Warning Message" @cwarning
  Write-Host "$Script:Now [ERROR] Error Message" @cerror
? ---------------------------------------------------------------------------------------------------------------------------------
#>

# Script Execution goes here
Start-Logging                                                                       # Start Transcription logging
Get-PSArch                                                                          # Get PowerShell Architecture version (x86 / x64)
Get-ScriptInfo                                                                      # Display Script Info
Clear-TransLogs                                                                     # Clear logs over 15 days old

Get-Now                                                                             # Get Current Date Time
Write-Host "$Script:Now [INFORMATION] $Script:File has been selected for processing" @chighlight
Write-Host ""

# Test and create folder structure
Invoke-TestPath -ParamPath $Script:dest                                             # Test and create destination path

Try{
    #^ What commands do you want to attempt?
}
Catch{
    #! Error handling
    Get-Now
    Write-Host "$Script:Now [ERROR] description of the error" @tred
    Write-Host $PSItem.Exception.Message @tred
}
Finally{
    # Clear the Error Queue
    $Error.Clear()                                                                  # Clear error log
}


Get-Now
Write-Host "================================================================================"  
Write-Host "================= $Script:Now Processing Finished ====================" 
Write-Host "================================================================================" 

Stop-Transcript                                                                     # Stop transcription

#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------