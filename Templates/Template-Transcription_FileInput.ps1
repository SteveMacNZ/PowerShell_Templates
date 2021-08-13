<#
.SYNOPSIS
  Synopsis here
.DESCRIPTION
  Script Desctription here
.PARAMETER None
  None
.INPUTS
  CSV file with following fields
  A                     A Description
  B                     B Description
  C                     C Description
  D                     D Description
.OUTPUTS
  Log file stored in same location as the CSV file
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  dd/mm/yy
  Purpose/Change: Initial script development
.LINK
  None
.EXAMPLE
  .\<scriptname>.ps1
  description of what the example does
.EXAMPLE
  .\<scriptname>.ps1
  description of what the example does 

#>

#requires -version 4
#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  #Script parameters go here
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Customer Specific
#$CustName = Read-Host "Enter Customer Short Name (e.g. Cloud Innovation = CINZ)"                # Customer Short Name

# Script scopped variables
$Script:Date                = Get-Date -Format yyyy-MM-dd                                               # Date format in yyyymmdd
$Script:File                = ''                                                                        # File var for Get-FilePicker Function
$Script:ScriptName          = 'Invoke-ScriptName'                                                       # Script Name used in the Open Dialogue
$Script:LogFile             = $PSScriptRoot + "\" + $Script:Date + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName           = ''                                                                        # Batch name variable placeholder
$Script:CSVFile             = $PSScriptRoot + "\" + $Script:Date + "_" + $Script:ScriptName + "_.csv"   # CSV Export location and name
$Script:GUID                = ''                                                                        # Script GUID
#^ Use New-Guid cmdlet to generate new script GUID for each version change of the script

#-----------------------------------------------------------[Hash Tables]----------------------------------------------------------
#* hash table for EventLogs
$E = @{
  N   = "PowerShell-Automation"                                                                         # Name of Event Log
  S   = "Scripts"                                                                                       # Name of Source
  Z   = 10048KB                                                                                         # Limit Event Log to 10MB                   
  I   = "Information"                                                                                   # Information Message Type
  W   = "Warning"                                                                                       # Warning Message Type
  E   = "Error"                                                                                         # Error Message Type
  A   = "Application"                                                                                   # Record EventLog creation in Application Log
  G   = 65000                                                                                           # Event ID 65000 = Completed Successfully
  O   = 65001                                                                                           # Event ID 65001 = Something Went Wrong (Warning)
  B   = 65002                                                                                           # Event ID 65002 = Something Failed (Error)
  1   = 65003                                                                                           # Event ID 65003 = User Remote Mailbox Created
  2   = 65004                                                                                           # Event ID 65004 = Shared Remote Mailbox Created
  3   = 65005                                                                                           # Event ID 65005 = Room Remote Mailbox Created
  4   = 65006                                                                                           # Event ID 65006 = Equipment Remote Mailbox Created
  5   = 65007                                                                                           # Event ID 65007 = Remote Mailbox Exists
  6   = 65008                                                                                           # Event ID 65008 = Remote Mailbox does not exist
}

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#& Start Transcriptions
Function Start-Logging{

  try {
      Stop-Transcript | Out-Null
  } catch [System.InvalidOperationException] { }                                          # jobs are running
  $ErrorActionPreference = "Continue"                                                     # Set Error Action Handling
  Get-Now                                                                                 # Get current date time
  Start-Transcript -path $Script:LogFile -IncludeInvocationHeader -Append                 # Start Transcription append if log exists
  Write-Host ''                                                                           # write Line spacer into Transcription file
  Write-Host ''                                                                           # write Line spacer into Transcription file
  Write-Host  "========================================================" 
  Write-Host  "====== $Script:Now Processing Started ========" 
  Write-Host  "========================================================" 
  Write-Host  ''
  
  Write-Host ''                                                                           # write Line spacer into Transcription file
}

#& Date time formatting for timestamped updated
Function Get-Now{
  $Script:Now = (get-date).tostring("[dd/MM HH:mm:ss:ffff]")
}

#& Clean up log files in script root older than 15 days
Function Clear-TransLogs{
  Get-Now
  Write-Output "$Script:Now - Cleaning up transaction logs over 15 days old"
  Get-ChildItem $PSScriptRoot -recurse "*$Script:ScriptName.log" -force | Where-Object {$_.lastwritetime -lt (get-date).adddays(-15)} | Remove-Item -force
}

#& FilePicker function for selecting input file via explorer window
Function Get-FilePicker {
  Param ()
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  $ofd = New-Object System.Windows.Forms.OpenFileDialog
  $ofd.InitialDirectory = $PSScriptRoot                                                         # Sets initial directory to script root
  $ofd.Title            = "Select file for $Script:ScriptName"                                  # Title for the Open Dialogue
  $ofd.Filter           = "Text files (*.txt)|*.txt|CSV File (*.csv)|*.csv|All files (*.*)|*.*" # Display All files / Txt / CSV
  $ofd.FilterIndex      = 2                                                                     # 3 Default to display All files
  $ofd.RestoreDirectory = $true                                                                 # Reset the directory path
  #$ofd.ShowHelp         = $true                                                                 # Legacy UI              
  $ofd.ShowHelp         = $false                                                                # Modern UI
  if($ofd.ShowDialog() -eq "OK") { $ofd.FileName }
  $Script:File = $ofd.Filename
}

#& Test for PowerShell Automation Event Log
Function Test-ELog{
  if ([System.Diagnostics.EventLog]::SourceExists($E.N) -eq $False) {
    Get-Now
    Write-Host "$Script:Now [ERROR] Eventlog does not exist - Please run .\Register-PSAutomation.ps1 and try again"
    Stop-Transcript
    exit
  }
  else{
    Write-Host "$Script:Now [INFORMATION] PowerShell Automation Event Log Exists"
  }
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
          Write-Host "$Script:Now [INFORMATION] Destination Path $($ParamPath) does not exist: creating...." -ForegroundColor Magenta -BackgroundColor White
          New-Item $ParamPath -ItemType Directory | Out-Null
          Get-Now
          Write-Verbose "$Script:Now [INFORMATION] Destination Path $($ParamPath) created"
      }
  }  
  Catch{
      #! Error handling for folder creation 
      Get-Now
      Write-Host "$Script:Now [Error] Error creating directories"
      Write-Host $PSItem.Exception.Message
      Stop-Transcript
      Break
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
<#
& Best veiwed and edited with Microsoft Visual Studio Code with colorful comments extension
^ Transcription logging formatting use Get-Now before write-host to return current timestamp into $Scipt:Now variable
  Write-Host "$Script:Now [INFORMATION] Information Message"
  Write-Host "$Script:Now [WARNING] Warning Message"
  Write-Host "$Script:Now [ERROR] Error Message"

^ Eventlog update
  Write-EventLog -LogName $E.[N,A] -Source $E.S -Message "Started Processing <what is this script>" -EventId $E.[G,O,B,1-5] -EntryType $E.[I,W,E]
#>

# Script Execution goes here
Start-Logging                                                                                       # Start Transcription logging
Clear-TransLogs                                                                                     # Clear logs over 15 days old
Test-ELog                                                                                           # Run function to test for PowerShell Automation Log

# Write update to PowerShell Automation Event Log
Get-Now
Write-Output "$Script:Now [INFORMATION] Writing script processing start to PowerShell Automation Event Log"
Write-EventLog -LogName $E.N -Source $E.S -Message "Started Processing <what is this script>" -EventId $E.G -EntryType $E.I

Get-FilePicker                                                                                      # Prompt user for CSV file

Get-Now                                                                                             # Get Current Date Time
Write-Host "$Script:Now [INFORMATION] $Script:File has been selected for processing" -ForegroundColor Magenta
Write-Host ""

#* Sets Batch Name to be name of the file selected in FilePicker function and uses in destination folder structures
$BatchNameTemp      = $Script:File.split("\")[-1]
$Script:BatchFolder = $BatchNameTemp.substring(0,($BatchNameTemp.length-4))
$Script:BFolder     = $Script:LogDir + "\" + $Script:BatchFolder


# Test and create folder structure
Invoke-TestPath -ParamPath $Script:LogDir
Invoke-TestPath -ParamPath $Script:BFolder

# Import CSV
<#Import-csv $Script:File -Delimiter "," | ForEach-Object {
  Try {
    Get-Now
    Write-Host "$Script:Now [INFORMATION] <What>" -ForegroundColor Yellow
    <do stuff>
  }
  Catch {
    Get-Now
    Write-Host "$Script:Now [ERROR] <what's the error>" -ForegroundColor Red
    Write-Host $PSItem.Exception.Message -ForegroundColor RED
    <do other stuff if required>
  }
  Finally{
    $Error.Clear()                                                                                  # Clear error log
  }
} #>

Write-Output ''                                                                                     # write Line spacer into Transcription file
Get-Now
Write-Output "$Script:Now [INFORMATION] Processing finished + any outputs"                          # Write Status Update to Transcription file

Get-Now
Write-Output  "========================================================" 
Write-Output  "======== $Script:Now Processing Finished =========" 
Write-Output  "========================================================"

Stop-Transcript                                                                                     # Stop transcription

#---------------------------------------------------------[Execution Completed]----------------------------------------------------------