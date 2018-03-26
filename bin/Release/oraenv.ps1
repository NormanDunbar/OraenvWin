<#
Oraenv for Windows (powershell version)
 
Calling Conventions:

    oraenv [oracle_sid]

Examples:
    oraenv - displays current settings
    oraenv azfs213 - sets environment for azfs213.
    oraenv broken - barfs!

If no sid is passed then:
    If ORAENV_ASK is YES then
        Prompt for a new ORACLE_SID, default is the current one.
    else
        Display the current oracle environment & exit.

    If a sid is passed then:
        If ORACLE_SID is currently not set then
            set the new sid's environment.
        
        If the new SID's ORACLE_HOME matches the current one then
            set the new ORACLE_SID, display the details & exit.

    Find the existing ORACLE_HOME in the PATH and remove all occurrences of _any_ folder beneath it.
    Set the new ORACLE_SID's environment, display the details & exit.
#>

param
(  
    [String]$NewSID
) 

function quit ()
{
    $env:NEW_SID = ''
    $env:NEW_HOME = ''
    $env:NEW_PATH = ''
    $env:OLD_ORACLE_HOME = ''
    $env:OLD_ORACLE_PATH = ''
    exit
}

function display_details ()
{
    Write-Output "ORACLE_SID = $env:ORACLE_SID"
    Write-Output "ORACLE_HOME = $env:ORACLE_HOME"
    Write-Output "NLS_DATE_FORMAT = $env:NLS_DATE_FORMAT"
    Write-Output "NLS_LANG = $env:NLS_LANG"
}

#Write-Host 'New SID:' $NewSID

$env:NEW_SID = ''
$env:NEW_HOME = ''
$env:NEW_PATH = ''
$env:OLD_ORACLE_HOME = ''
$env:OLD_ORACLE_PATH = ''

# Keep the old stuff we might be changing these.
# However, only if we have current settings, which we might not!

if (-not [string]::IsNullOrEmpty($env:ORACLE_HOME))
{
    $env:OLD_ORACLE_HOME = $env:ORACLE_HOME
    $env:OLD_ORACLE_PATH = $env:ORACLE_PATH
}
else {
    $env:OLD_ORACLE_HOME = 'NOT_SET'
    $env:OLD_ORACLE_PATH = 'NOT_SET'
}

#Write-Output $env:OLD_ORACLE_HOME
#Write-Output $env:OLD_ORACLE_PATH

# No SID supplied = display current details and exit, UNLESS
# ORAENV_ASK is set to YES.

# We have a SID? Skip the next bit.
if (-not [string]::IsNullOrEmpty($NewSID))
{
    $env:NEW_SID = $NewSID
}    
else {
    if ($env:ORAENV_ASK -ne 'YES')
    {
        Write-Output 'Current Environment details are:'
        display_details
        quit
    }
    else {
        #Ask for a new ORACLE_SID, defaulting to the current one.
        if (($NewSID = read-host "Enter a new value for ORACLE_SID [$env:OLD_ORACLE_SID]") -eq ''){$env:OLD_ORACLE_SID}else{$NewSID}
    }
}    
