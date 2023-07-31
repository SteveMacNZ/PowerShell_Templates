<#
.SYNOPSIS
  what does this script do?
.DESCRIPTION
  what does this script do? extended description 
.PARAMETER None
  None
.INPUTS
  What Inputs  
.OUTPUTS
  What outputs
.NOTES
  Version:        1.0.0.x
  Author:         Steve McIntyre
  Creation Date:  DD/MM/20YY
  Purpose/Change: Initial Release
.LINK
  None
.EXAMPLE
  ^ . Invoke-What.ps1
  does what with example of cmdlet
  Invoke-What.ps1

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
. Get-CommonFunctions.ps1                                 # Include Common Functions

#endregion
#region -------------------------------------------------------[Declarations]------------------------------------------------------

# Script sourced variables for General settings and Registry Operations
$Script:Date        = Get-Date -Format yyyy-MM-dd                                   # Date format in yyyy-mm-dd
$Script:Now         = ''                                                            # script sourced veriable for Get-Now function
$Script:ScriptName  = ''                                                            # Script Name used in the Open Dialogue
$Script:dest        = "$PSScriptRoot\Exports"                                       # Destination path
$Script:LogDir      = "$PSScriptRoot\Logs"                                          # Logdir for Clear-TransLogs function for $PSScript Root
$Script:LogFile     = $Script:LogDir + "\" + $Script:Date + "_" + $env:USERNAME + "_" + $Script:ScriptName + ".log"    # logfile location and name
$Script:BatchName   = ''                                                            # Batch name variable placeholder
$Script:GUID        = '00000000-0000-0000-0000-000000000000'                        # Script GUID
  #^ Use New-Guid cmdlet to generate new script GUID for each version change of the script
[version]$Script:Version  = '0.0.0.0'                                               # Script Version Number
$Script:Client      = ''                                                            # Set Client Name - Used in Registry Operations
$Script:WHO         = whoami                                                        # Collect WhoAmI
$Script:Desc        = ""                                                            # Description displayed in Get-ScriptInfo function
$Script:Desc2       = ""                                                            # Description2 displayed in Get-ScriptInfo function
$Script:PSArchitecture = ''                                                         # Place holder for x86 / x64 bit detection

#^ File Picker / Folder Picker Setup
[System.IO.FileInfo]$Script:File  = ''                                              # File var for Get-FilePicker Function
$Script:FPDir       = '$PSScriptRoot'                                               # File Picker Initial Directory
$Script:FileTypes   = "Text files (*.txt)|*.txt|CSV File (*.csv)|*.csv|All files (*.*)|*.*" # File types to be listed in file picker
$Script:FileIndex   = "2"                                                           # What file type to set as default in file picker (based on above order)

#endregion
#region --------------------------------------------------------[Hash Tables]------------------------------------------------------

#& any script specific hash tables that are not included in Get-CommonFunctions.ps1

#endregion
#region -------------------------------------------------------[Functions]---------------------------------------------------------

#& any script specific funcitons that are not included in Get-CommonFunctions.ps1

#endregion
#region ------------------------------------------------------------[Classes]-------------------------------------------------------------

#& any script specific classes that are not included in Get-CommonFunctions.ps1

<#
# Example Class - constuct and usage
Class ClassName{
  # $classresult = [ClassName]::new("$WhatString","$WhatINT","$WhatBool")           # creates a new class object
  # $Script:ClassArray.add($classresult) | Out-Null                                 # writes the class object to the Class array
  # $Script:ClassArray | Export-Csv -Path $ClassReport -NoTypeInformation           # writes the class array out to CSV file
  [String]$WhatString
  [INT]$WhatINT 
  [Bool]$WhatBool
  
  # constructor
  ClassName([String]$WhatString, [INT]$WhatINT, [Bool]$WhatBool){
    $this.WhatString = $WhatString
    $this.WhatINT = $WhatINT
    $this.WhatBool = $WhatBool
  } 
}
#>

#endregion
#region -----------------------------------------------------------[Execution]------------------------------------------------------------
<#
? ---------------------------------------------------------- [NOTES:] -------------------------------------------------------------
& Best veiwed and edited with Microsoft Visual Studio Code with colorful comments extension
^ Transcription logging formatting use the following functions to Write-Host messages
  Write-InfoMsg "Message" writes informational message as Write-Host "$Script:Now [INFORMATION] Information Message" format
  Write-InfoHighlightedMsg "Message" writes highlighted information message as Write-Host "$Script:Now [INFORMATION] Highlighted Information Message" format
  Write-SuccessMsg "Message" writes success message as Write-Host "$Script:Now [SUCCESS] Warning Message" format"
  Write-WarningMsg "Message" writes warning message as Write-Host "$Script:Now [WARNING] Warning Message" format
  Write-ErrorMsg "Message" writes error message as Write-Host "$Script:Now [ERROR] Error Message" format
  Write-ErrorAndExitMsg "Message" writes error message as Write-Host "$Script:Now [ERROR] Error Message" format and exits script
? ---------------------------------------------------------------------------------------------------------------------------------
#>

Start-Logging                                                                           # Start Transcription logging
Get-PSArch                                                                              # Get PS Architecture
Get-ScriptInfo                                                                          # Display Script Info
Clear-TransLogs                                                                         # Clear logs over 15 days old

Invoke-TestPath -ParamPath $Script:dest                                                 # Test and create folder structure 
Invoke-TestPath -ParamPath $Script:LogDir                                               # Test and create folder structure

<# Detect closest domain controller for Active Directory work
Write-InfoMsg "Detecting nearest AD Domain Controller"

$Script:NearestDC = (Get-ADDomainController -Discover -NextClosestSite).Name
Write-InfoHighlightedMsg "$Script:NearestDC selected as AD Domain Controller"
#>

<#
# Example foreach loop with input / output count validation
#$What = Import-csv $Script:File -Delimiter ","
$What = "cmdlet to collect required information e.g., Get-ADUser"
$counter = 0
$maximum = $What.Count  # number of items to be processed

Write-InfoHighlightedMsg "$maximum What Objects found"
Write-Host ""
Foreach ($W in $What)  {
  
  $counter++
  $percentCompleted = $counter * 100 / $maximum

  $message = '{0:p1} completed, processing {1}.' -f ( $percentCompleted/100), $W.Value
  Write-Progress -Activity 'I am busy' -Status $message -PercentComplete $percentCompleted

  Write-InfoMsg "processing what for $($W.Value)"

  # doing stuff here
  Try{
    Write-InfoMsg "What is being attempted"
    # try stuff
  }
  Catch{
    Write-ErrorMsg "Summary of the error message"
    Write-Host $PSItem.Exception.Message -ForegroundColor RED             # Error message details
  }
  Finally{
    $Error.Clear()                                                        # Clear error log
  }

  $classresult = [ClassName]::new("$WhatString","$WhatINT","$WhatBool")
  Write-SuccessMsg "$($W.Value) written to class object"
  $Script:ClassResults.add($classresult) | Out-Null

  ("$WhatString","$WhatINT","$WhatBool",$AnyOtherVarsThatNeedtobeCleared) = $null

}

$ClassReport = $Script:dest + "\" + $Script:Date + "_ClassReport.csv"

Write-InfoMsg "Writing class objects to csv file"
$Script:ClassArray | Export-Csv -Path $ClassReport -NoTypeInformation

# Input / Output comparsion
Write-Host ""
Write-Host '--------------------------------------------------------------------------------'
Write-Host '|                      Input / Output CSV Count Comparsion                     |'
Write-Host '--------------------------------------------------------------------------------'
$OutputObject = Import-csv "$ClassReport" -Delimiter ","        # Read Output for input/output comparsion
$OutputCount = $OutputObject.count
If ($maximum -eq $OutputCount){
  Get-Now
  Write-Host "$Script:Now [COUNTS] CSV Input [$maximum] and Output [$OutputCount] counts match" @chighlight
}
else{
  Get-Now
  Write-Host "$Script:Now [COUNTS] CSV Input [$maximum] and Output [$OutputCount] counts don't match" @cerror
}
Write-Host '--------------------------------------------------------------------------------'
Write-Host ''
#>

Write-Host ''
Get-Now
Write-Host "$Script:Now [INFORMATION] Processing finished + any outputs"                          

Get-Now
Write-Host "================================================================================"  
Write-Host "================= $Script:Now Processing Finished ====================" 
Write-Host "================================================================================" 

Stop-Transcript
#endregion
#---------------------------------------------------------[Execution Completed]----------------------------------------------------------