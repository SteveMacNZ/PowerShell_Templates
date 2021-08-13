<#
.SYNOPSIS
  Tests for PowerShell-Automation Event log and creates if not existing Required Administrative rigths
.DESCRIPTION
  Tests for PowerShell-Automation Event log and creates if not existing Required Administrative rigths
.PARAMETER None
  None
.INPUTS
  None
.OUTPUTS
  Log file for transcription logging
.NOTES
  Version:        1.0
  Author:         Steve McIntyre, Fujitsu NZ     
  Creation Date:  25/03/2020
  Purpose/Change: Initial Script
  Version:        1.1
  Author:         Steve McIntyre, Fujitsu NZ     
  Creation Date:  12/08/2021
  Purpose/Change: Updated with new script formatting and functions
.LINK
  None
.EXAMPLE
  .\RegisterPSAutomation.ps1
  Creates PowerShell Auotmation event log
  
#>


#requires -version 4 -RunAsAdministrator
#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  # Script parameters go here
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

# Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Customer Specific
#$CustName = "CINZ"                                                                                      # Customer Short Name

# Script scopped variables
$Script:Date                = Get-Date -Format yyyy-MM-dd                                               # Date format in yyyymmdd
$Script:File                = ''                                                                        # File var for Get-FilePicker Function
$Script:ScriptName          = 'Register-PSAutomation'                                                   # Script Name used in the Open Dialogue
$Script:LogFile             = $PSScriptRoot + "\" + $Script:Date + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:GUID                = '086ae21d-87c1-4b64-ab70-a28fb2f781b7'                                    # Script GUID
#^ Use New-Guid cmdlet to generate new script GUID for each version change of the script

#-----------------------------------------------------------[Hash Tables]-----------------------------------------------------------

#* hash table for EventLogs
$E = @{
  N   = "PowerShell-Automation"                                                           # Name of Event Log
  S   = "Scripts"                                                                         # Name of Source
  Z   = 10048KB                                                                           # Limit Event Log to 10MB                   
  I   = "Information"                                                                     # Information Message Type
  W   = "Warning"                                                                         # Warning Message Type
  E   = "Error"                                                                           # Error Message Type
  A   = "Application"                                                                     # Record EventLog creation in Application Log
  G   = 65000                                                                             # Event ID 65000 = Completed Successfully
  O   = 65001                                                                             # Event ID 65001 = Something Went Wrong (Warning)
  B   = 65002                                                                             # Event ID 65002 = Something Failed (Error)
  1   = 65003                                                                             # Event ID 65003 = User Remote Mailbox Created
  2   = 65004                                                                             # Event ID 65004 = Shared Remote Mailbox Created
  3   = 65005                                                                             # Event ID 65005 = Room Remote Mailbox Created
  4   = 65006                                                                             # Event ID 65006 = Equipment Remote Mailbox Created
  5   = 65007                                                                             # Event ID 65007 = Remote Mailbox Exists
  6   = 65008                                                                             # Event ID 65008 = Remote Mailbox does not exist
}

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#& Date time formatting for timestamped updated
Function Get-Now{
  $Script:Now = (get-date).tostring("[dd/MM HH:mm:ss:ffff]")
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Test for PowerShell-Automation Event log and create if it does not exist
if ([System.Diagnostics.EventLog]::SourceExists($E.N) -eq $False) {
    Get-Now                                                                                 # Get Current Data
    Write-Host "$Script:Now [INFORMATION] Creating PowerShell-Automation Event Log"
    New-EventLog -LogName $E.N -Source $E.S                                                 # Create Event Log
    Limit-EventLog -OverflowAction OverWriteAsNeeded -MaximumSize $E.Z -LogName $E.N        # Set Event Log
    Write-EventLog -LogName $E.N -Source $E.S -Message "PowerShell Automation Event Log Created" -EventId $E.G -EntryType $E.I # Write Status to new Log
    Write-EventLog -LogName $E.A -Source EventSystem -Message "PowerShell-Automation Event Log Created by Script" -EventId $E.G -EntryType $E.I    # Record Event Log to Application log
   }

#---------------------------------------------------------[Execution Completed]----------------------------------------------------------