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
  ^ .\<scriptname>.ps1
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

# Script sourced variables for General settings and Registry Operations
$Script:Date        = Get-Date -Format yyyy-MM-dd                                   # Date format in yyyy-mm-dd
[System.IO.FileInfo]$Script:File  = ''                                              # File var for Get-FilePicker Function
$Script:ScriptName  = 'Invoke-ScriptName'                                           # Script Name used in the Open Dialogue
#$Script:dest        = $PSScriptRoot                                                 # Destination path - uncomment to use PS script root
$Script:dest        = "$($env:ProgramData)\What\Path"                               # Destination Path - comment to use PS Script root
$Script:LogFile     = $Script:dest + "\" + $Script:Date + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:CSVFile     = $Script:dest + "\" + $Script:Date + "_" + $Script:ScriptName + "_.csv"   # CSV Export location and name
$Script:Details     = Get-ComputerInfo                                              # Get Computer Info
$Script:GUID        = ''                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
[version]$Script:Version  = '0.0.0.0'                                               # Script Version Number
$Script:Client      = ''                                                            # Set Client Name - Used in Registry Operations
$Script:Operation   = 'Install'                                                     # Operations Feild for registry
$Script:Source      = 'Script'                                                      # Source (Script / MSI / Scheduled Task etc)
$Script:PackageName = $Script:ScriptName                                            # Packaged Name - Used in Registry Operations (may be same as script name)
$Script:RegPath     = "HKLM:\Software\$Script:Client\$Script:Source\$Script:PackageName\$Script:Operation"   # Registry Hive Location for Registry Operations
$Script:Desc        = "ShortDesc for $Script:Client"
$Script:Desc2       = "Description of Script"

# Script sourced variables for Task Schedule
$Script:TaskName    = ''                                                            # Scheduled Task Name
$Script:TaskDesc    = ''                                                            # Description for Scheduled Task
$Script:timespan    = New-Timespan -minutes 5                                       # Scheduled Task Timespan
$Script:triggers    = @()                                                           # Scheduled Task Triggers Array 
$Script:triggers    += New-ScheduledTaskTrigger -Daily -At 9am                      # Daily at 9 am
$Script:triggers    += New-ScheduledTaskTrigger -AtLogOn -RandomDelay $timespan     # At Logon with random delay
$Script:triggers    += New-ScheduledTaskTrigger -AtStartup -RandomDelay $timespan   # At Startup with randon delay

#-----------------------------------------------------------[Hash Tables]----------------------------------------------------------
#* Hash table for Write-Host Errors to be used as spatted
$cerror = @{ForeGroundColor = "Red"; BackgroundColor = "white"}
#* Hash table for Write-Host Warnings to be used as spatted
$cwarning = @{ForeGroundColor = "Magenta"; BackgroundColor = "white"}
#* Hash table for Write-Host highlighted to be used as spatted
$chighlight = @{ForeGroundColor = "Blue"; BackgroundColor = "white"}

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

#& Display ScriptInfo
Function Get-ScriptInfo{
    
  Write-Host "#==============================================================================="
  Write-Host "# Name:             $Script:ScriptName"
  Write-Host "# Version:          $Script:Version"
  Write-Host "# GUID:             $Script:GUID"
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
    Write-Host "$Script:Now [ERROR] Eventlog does not exist - Please run .\Register-PSAutomation.ps1 and try again" @cerror
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

#& Task Scheduler Function
Function Register-Task{
  Get-Now
  Write-Host "$Script:Now [INFORMATION] <What/Why details here> creating Scheduled Task" 
  
  # Check to see if already scheduled
  $existingTask = Get-ScheduledTask -TaskName $Script:TaskName -ErrorAction SilentlyContinue
  if ($null -ne $existingTask){
      Get-Now
      Write-Host "$Script:Now [INFORMATION] Scheduled task already exists."
  }

  # Copy myself to a safe place if not already there
  if (-not (Test-Path "$Script:dest\$Script:ScriptName.ps1")){
    Get-Now
    Write-Host "$Script:Now [INFORMATION] Copying Script to $Script:dest\$Script:ScriptName.ps1"
    Copy-Item $PSCommandPath "$Script:dest\$Script:ScriptName.ps1"
  }

  # Create the scheduled task action
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy bypass -WindowStyle Hidden -File $Script:dest\$Script:ScriptName.ps1"

  # Register the scheduled task
  Register-ScheduledTask -User SYSTEM -Action $action -Trigger $Script:triggers -TaskName $Script:TaskName -Description $Script:TaskDesc -Force
  Get-Now
  Write-Host "$Script:Now [INFORMATION] Scheduled task created." 
}

#& Checks for Scheduled Task and Removes Scheduled Task if successful
Function Invoke-CheckTask{
  $TaskExists = Get-ScheduledTask -TaskName $Script:TaskName -ErrorAction SilentlyContinue
  If ($TaskExists -eq $true){
    Get-Now
    Disable-ScheduledTask -TaskName $Script:TaskName -ErrorAction Ignore
    Unregister-ScheduledTask -TaskName $Script:TaskName -Confirm:$false -ErrorAction Ignore
    Write-Host "$Script:Now [INFORMATION] Scheduled task unregistered."
  }
  else{
    Get-Now
    Write-Host "$Script:Now [INFORMATION] Scheduled task does not exist contuining..."
  }
}

#& Write Registry Hive
Function Write-Reg{
  Get-Now
  Write-Host "$Script:Now [INFORMATION] Creating Registry Hive: $Script:RegPath"
  if(!(Test-Path $Script:RegPath)){
      New-Item -Path $Script:RegPath -Force | Out-Null 
  }
}

#& Test and load SCCM Module
Function Test-SCCMModule{
  Get-Now
  Write-Host "$Script:Now [INFORMATION] Testing for SCCM Module"
  # Import the ConfigurationManager.psd1 module
  if($null -eq (Get-Module ConfigurationManager)) {
    Get-Now
    Write-Host "$Script:Now [INFORMATION] SCCM Module not loaded. Loading Module."
    Try{
      Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @Script:initParams
      Get-Now
      Write-Host "$Script:Now [INFORMATION] SCCM Module has been loaded"
    }
    Catch{
      #! Error handling for Module 
      Get-Now
      Write-Host "$Script:Now [Error] Unable to load SCCM Module" @cerror
      Write-Host $PSItem.Exception.Message
      Stop-Transcript
      Break  
    }
    Finally{
      $Error.Clear()                                                                     # Clear error log
    }       
  }
  else{
    Get-Now
    Write-Host "$Script:Now [INFORMATION] SCCM Module already loaded."   
  }
}

#& Test and connect to site drive
Function Test-CMSiteDrive{
Get-Now
$CMSite="$(Get-PSDrive -PSProvider CMSite)`:"
Write-Host "$Script:Now [INFORMATION] Setting Location to $Script:SiteCode" 
Set-Location $CMSite
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
<#
? ---------------------------------------------------------- [NOTES:] -------------------------------------------------------------
& Best veiwed and edited with Microsoft Visual Studio Code with colorful comments extension
^ Transcription logging formatting use Get-Now before write-host to return current timestamp into $Scipt:Now variable
  Write-Host "$Script:Now [INFORMATION] Information Message"
  Write-Host "$Script:Now [INFORMATION] Highlighted Information Message" @chighlight
  Write-Host "$Script:Now [WARNING] Warning Message" @cwarning
  Write-Host "$Script:Now [ERROR] Error Message" @cerror

^ Eventlog update
  Write-EventLog -LogName $E.[N,A] -Source $E.S -Message "Started Processing <what is this script>" -EventId $E.[G,O,B,1-5] -EntryType $E.[I,W,E]
? ---------------------------------------------------------------------------------------------------------------------------------
#>

# Script Execution goes here
Start-Logging                                                                                       # Start Transcription logging
Get-ScriptInfo                                                                          # Display Script Info
Clear-TransLogs                                                                                     # Clear logs over 15 days old
Test-ELog                                                                                           # Run function to test for PowerShell Automation Log

# Write update to PowerShell Automation Event Log
Get-Now
Write-Host "$Script:Now [INFORMATION] Writing script processing start to PowerShell Automation Event Log"
Write-EventLog -LogName $E.N -Source $E.S -Message "Started Processing <what is this script>" -EventId $E.G -EntryType $E.I

Get-FilePicker                                                                                      # Prompt user for CSV file

Get-Now                                                                                             # Get Current Date Time
Write-Host "$Script:Now [INFORMATION] $Script:File has been selected for processing" @chighlight
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
    Write-Host "$Script:Now [ERROR] <what's the error>" @cerror
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
Write-Host "================================================================================"  
Write-Host "================= $Script:Now Processing Finished ====================" 
Write-Host "================================================================================" 

Stop-Transcript                                                                           # Stop transcription

#---------------------------------------------------------[Execution Completed]----------------------------------------------------------