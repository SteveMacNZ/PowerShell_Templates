<#
.SYNOPSIS
  Common Function Include Script
.DESCRIPTION
  Common Functions Include Script - containing common functions to be imported into the migration scripts using the 
.PARAMETER None
  None
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Steve McIntyre
  Creation Date:  13/09/2022
  Purpose/Change: Initial Release
.LINK
  None
.EXAMPLE
  ^ . Get-CommonFunctions.ps1
  To import standard common Functions script as an include

#>

#requires -version 4
#region ------------------------------------------------------[Script Parameters]--------------------------------------------------

Param (
  #Script parameters go here
)

#endregion
#region ------------------------------------------------------[Initialisations]----------------------------------------------------

#& Global Error Action
#$ErrorActionPreference = 'SilentlyContinue'

#& Module Imports
#Import-Module ActiveDirectory

#& Includes - Scripts & Modules
#. .\Get-CommonFunctions.ps1                          # Include Common Functions

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
#* Hash table for Write-Host Errors to be used as spatted
$cerror = @{ForeGroundColor = "Red"; BackgroundColor = "white"}
#* Hash table for Write-Host Warnings to be used as spatted
$cwarning = @{ForeGroundColor = "Magenta"; BackgroundColor = "white"}
#* Hash table for Write-Host highlighted to be used as spatted
$chighlight = @{ForeGroundColor = "Blue"; BackgroundColor = "white"}

#* Hash table for Write-Host green text to be used as spatted
$tgreen = @{ForeGroundColor = "Green"}
#* Hash table for Write-Host red text to be used as spatted
$tred = @{ForeGroundColor = "Red"}

#^ Dummy Write-host for spatted formatting
Write-Host @chighlight
Write-Host @cwarning
Write-Host @cerror
Write-Host @tgreen
Write-Host @tred

#endregion
#region -------------------------------------------------------[Functions]---------------------------------------------------------

#& Start Transcriptions
Function Start-Logging{
  try {
    Stop-Transcript | Out-Null
  } catch [System.InvalidOperationException] { }                                     # jobs are running
  $ErrorActionPreference = "Continue"                                                # Set Error Action Handling
  Get-Now                                                                            # Get current date time
  Start-Transcript -path $Script:LogFile -IncludeInvocationHeader -Append            # Start Transcription append if log exists
  Write-Host ''                                                                      # write Line spacer into Transcription file
  Write-Host ''                                                                      # write Line spacer into Transcription file
  Write-Host "================================================================================" 
  Write-Host "================== $Script:Now Processing Started ====================" 
  Write-Host "================================================================================"  
  Write-Host ''

  Write-Host ''                                                                       # write Line spacer into Transcription file
}

#& Date time formatting for timestamped updated
Function Get-Now{
  # PowerShell Method - uncomment below is .NET is unavailable
  #$Script:Now = (get-date).tostring("[dd/MM HH:mm:ss:ffff]")
  # .NET Call which is faster than PowerShell Method - comment out below if .NET is unavailable
  $Script:Now = ([DateTime]::Now).tostring("[dd/MM HH:mm:ss:ffff]")
}

#& Clean up log files in script root older than 15 days
Function Clear-TransLogs{
  Get-Now
  Write-Host "$Script:Now - Cleaning up transaction logs over 15 days old" @cwarning
  Get-ChildItem $Script:LogDir -recurse "*$Script:ScriptName.log" -force | Where-Object {$_.lastwritetime -lt (get-date).adddays(-15)} | Remove-Item -force
}

#& FilePicker function for selecting input file via explorer window
Function Get-FilePicker {
  Param ()
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  $ofd = New-Object System.Windows.Forms.OpenFileDialog
  $ofd.InitialDirectory = $Script:FPDir                                                         # Sets initial directory to script root
  $ofd.Title            = "Select file for $Script:ScriptName"                                  # Title for the Open Dialogue
  $ofd.Filter           = $Script:FileTypes                                                     # File Types filter
  $ofd.FilterIndex      = $Script:FileIndex                                                     # What file type to default to
  $ofd.RestoreDirectory = $true                                                                 # Reset the directory path
  #$ofd.ShowHelp         = $true                                                                 # Legacy UI              
  $ofd.ShowHelp         = $false                                                                # Modern UI
  if($ofd.ShowDialog() -eq "OK") { $ofd.FileName }
  $Script:File = $ofd.Filename
}

#& TestPath function for testing and creating directories
Function Invoke-TestPath{
  [CmdletBinding()]
  param (
    #^ Path parameter for testing/creating destination paths
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String]
    $ParamPath
  )
  Try{
    # Check to see if the report location exists, if not create it
    if ((Test-Path -Path $ParamPath -PathType Container) -eq $false){
      Get-Now
      Write-Host "$Script:Now [INFORMATION] Destination Path $($ParamPath) does not exist: creating...." @chighlight
      New-Item $ParamPath -ItemType Directory | Out-Null
      Get-Now
      Write-Verbose "$Script:Now [INFORMATION] Destination Path $($ParamPath) created"
    }
  }  
  Catch{
    #! Error handling for folder creation 
    Get-Now
    Write-Host "$Script:Now [Error] Error creating directories" @cerror
    Write-Host $PSItem.Exception.Message
    Stop-Transcript
    Break
  }
}

#& Display ScriptInfo
Function Get-ScriptInfo{
    
  Write-Host "#==============================================================================="
  Write-Host "# Name:             $Script:ScriptName"
  Write-Host "# Version:          $Script:Version"
  Write-Host "# GUID:             $Script:GUID"
  Write-Host "# Running As:       $Script:WHO"
  Write-Host "# PS Architecture:  $Script:PSArchitecture"
  Write-Host "# Description:"
  Write-Host "# $Script:Desc"
  Write-Host "# $Script:Desc2"
  Write-Host "#-------------------------------------------------------------------------------"
  Write-Host "# Log:              $Script:LogFile"
  Write-Host "# Exports:          $Script:dest"
  Write-Host "#==============================================================================="
  Write-Host ""
  Write-Host ""
  Write-Host ""
}

Function Get-PSArch{
  # Determines if PowerShell is running as a x86 or x64 bit process
  $Arch = [intptr]::Size

  If ($Arch -eq 4){Write-Host "PowerShell is running the script as x86"; $Script:PSArchitecture = "x86 [32 bit]"}
  If ($Arch -eq 8){Write-Host "PowerShell is running the script as x64"; $Script:PSArchitecture = "x64 [64 bit]"}
}

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



#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------