// Bicep Template File
/*
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
*/

// ------------------------------------------------------[Script Parameters]--------------------------------------------------
@description('What for what')
param astring string = 'Default Value'                                // comment on parameter

@description('What for what')
param boolianvalue bool                                               // comment on parameter

@description('What for what')
param arrayobject array                                               // comment on parameter

@description('What for what')
param NumInt int                                                      // comment on parameter

@description('What for what')
param AnObj object                                                    // comment on parameter

param location string = resourceGroup().location                      // determine location based off resource group

@description('''
example: Storage account name restrictions:
- Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
- Your storage account name must be unique within Azure. No two storage accounts can have the same name.
''')
@minLength(3)
@maxLength(24)
param storageAccountName string

// -------------------------------------------------------[Declarations]------------------------------------------------------

var variablename1 = 'var-value'                                       // comment for variable purpose
var variablename2 = 'var-value'                                       // comment for variable purpose
var variablename3 = 'var-value'                                       // comment for variable purpose
var variablename4 = 'var-value'                                       // comment for variable purpose

// --------------------------------------------------------[Modules]----------------------------------------------------------

// Comment for Module
module modname './pathtobicep.bicep' = {
  name: 'name'
  params: {
    pramname1: 'value'
    pramname2: 'value'
  }
}

// ----------------------------------------------------------[What]------------------------------------------------------------

