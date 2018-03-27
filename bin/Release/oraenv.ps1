<#
Oraenv for Windows (powershell version)
 
Calling Conventions:

    oraenv [oracle_sid]

Examples:
    oraenv - displays current settings
    oraenv orcl - sets environment for orcl
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

Param
(  
    [String] $NewSID
) 

function quit ()
{
    exit
}

function display_details ()
{
    Write-Output "ORACLE_SID=$env:ORACLE_SID"
    Write-Output "ORACLE_HOME=$env:ORACLE_HOME"
    Write-Output "NLS_DATE_FORMAT=$env:NLS_DATE_FORMAT"
    Write-Output "NLS_LANG=$env:NLS_LANG `n"
}

#Write-Output 'New SID:' $NewSID

$oraenv = @{}

# Keep the old stuff we might be changing these.
# However, only if we have current settings, which we might not!

if (-not [string]::IsNullOrEmpty($env:ORACLE_SID))
{
    $oraenv.Add("OldOracleHome", $env:ORACLE_HOME)
    $oraenv.Add("OldOracleSID", $env:ORACLE_SID)
}
else {
    $oraenv.Add("OldOracleHome", 'NOT_SET')
    $oraenv.Add("OldOracleSID", 'NOT_SET')
}

# We have a SID? Skip the next bit.
if (-not [string]::IsNullOrEmpty($NewSID))
{
    $oraenv.NewOracleSID = $NewSID
}    
else {
    # No SID supplied = display current details and exit, UNLESS ORAENV_ASK is set to YES.
    if ($env:ORAENV_ASK -ne 'YES')
    {
        Write-Output "`nCurrent Environment details are:"
        display_details
        quit
    }
    else {
        while ([string]::IsNullOrEmpty($NewSID))
        {
            #Ask for a new ORACLE_SID, defaulting to the current one.
            $NewSID = read-host "Enter a new value for ORACLE_SID [$($oraenv.OldOracleSID)]"
            if (([string]::IsNullOrEmpty($NewSID) -and $oraenv.OldOracleSID -ne "NOT_SET") -Or (-not [string]::IsNullOrEmpty($NewSID)))
            {
                $oraenv.NewOracleSID = $NewSID
            } 
        }
    }
}

# Get Oracle Home for the new sid
$oraenv.NewOracleHome = cmd.exe /c "DBHome" $($oraenv.NewOracleSID) | Out-String
$oraenv.NewOracleHome = $oraenv.NewOracleHome -replace '(?:\s|\r|\n)',''

if ([string]::IsNullOrEmpty($oraenv.NewOracleHome))
{
    Write-Output "Invalid SID supplied: $($oraenv.NewOracleSID)"
    quit
}

#Do we need to change PATH? We will always have to change it
#if this is the first time that ORACLE_SID or ORACLE_HOME are being set.
if ($oraenv.OldOracleSID -eq "NOT_SET")
{
    $env:ORACLE_SID = $oraenv.NewOracleSID
    $env:ORACLE_HOME = $oraenv.NewOracleHome
    $env:PATH="$($oraenv.NewOracleHome)\bin;$env:PATH"
} elseif ($oraenv.OldOracleHome -eq $oraenv.NewOracleHome) {
    # No change to HOME (or SID perhaps), so PATH is ok, just set SID.
    $env:ORACLE_SID = $oraenv.NewOracleSID    
} else {
    # So, we are here, we have to remove the old home from the path and add in the new one.
    $oraenv.OldOracleHome = cmd.exe /c "DBHome" $($oraenv.OldOracleSID) | Out-String
    $oraenv.OldOracleHome = $oraenv.OldOracleHome -replace '(?:\s|\r|\n)',''

    # Now remove the old oracle home from the path - if it's valid.
    if (-not [string]::IsNullOrEmpty($oraenv.OldOracleHome)) {
      $newpath = $env:PATH
      # Remove unwanted elements
      $newpath = ($newpath.Split(';') | Where-Object { $_ -ne "$($oraenv.OldOracleHome)\bin" }) -join ';'
    }

    #And finally, add the new oracle home to the path.
    $env:ORACLE_SID = $oraenv.NewOracleSID
    $env:ORACLE_HOME = $oraenv.NewOracleHome
    $env:OLD_PATH = $env:PATH
    $env:PATH="$($oraenv.NewOracleHome)\bin;$newpath"
}

# We always set these regardless.
$env:NLS_DATE_FORMAT='yyyy/mm/dd hh24:mi:ss'
$env:NLS_LANG='AMERICAN_AMERICA.WE8ISO8859P1'

Write-Output "`nEnvironment set as follows:"
display_details