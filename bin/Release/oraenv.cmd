@echo off
Rem ================================================================
rem Oraenv for Windows.
rem 
rem Calling Conventions:
rem
rem oraenv [oracle_sid]
rem 
Rem ================================================================
rem Examples:
rem
rem oraenv - displays current settings
rem oraenv azfs213 - sets environment for azfs213.
rem oraenv broken - barfs!
Rem ================================================================
rem If no sid is passed then:
rem    If ORAENV_ASK is YES then
rem       Prompt for a new ORACLE_SID, default is the current one.
rem    else
rem       Display the current oracle environment & exit.
rem
rem If a sid is passed then:
rem    If ORACLE_SID is currently not set then
rem       set the new sid's environment.
rem
rem    If the new SID's ORACLE_HOME matches the current one then
rem       set the new ORACLE_SID, display the details & exit.
rem
rem    Find the existing ORACLE_HOME in the PATH and remove all
rem    occurrences of _any_ folder beneath it.
rem    Set the new ORACLE_SID's environment, display the details
rem    & exit.
Rem ================================================================

set NEW_SID=
set NEW_HOME=
set NEW_PATH=
set OLD_ORACLE_HOME=
set OLD_ORACLE_PATH=

rem Keep the old stuff we might be changing these.
rem However, only if we have current settings, which we might not!
    if "%ORACLE_SID%" NEQ "" (
        set OLD_ORACLE_HOME=%ORACLE_HOME%
        set OLD_ORACLE_SID=%ORACLE_SID%
    ) else (
        set OLD_ORACLE_HOME=NOT_SET
        set OLD_ORACLE_SID=NOT_SET
    )    
    
rem No SID supplied = display current details and exit, UNLESS
rem ORAENV_ASK is set to YES.

    rem We have a SID? Skip the next bit.
    if "%1" NEQ "" (
        set NEW_SID=%1
        goto :tidy_path
    )    
    
    rem No SID supplied, If ORAENV_ASK not = yes, we just display details.
    if /i "%ORAENV_ASK%" NEQ "YES" (
        echo.
        echo Current Environment details are:
        goto :display_details
    )
    
:ask_me_again
    rem Ask for a new ORACLE_SID, defaulting to the current one.
    echo.
    set /p NEW_SID=Enter a new value for ORACLE_SID [%OLD_ORACLE_SID%] : 
    
    rem Did we get a new SID?.
    if /i "%NEW_SID%" NEQ "" (
        goto :tidy_path
    )

    rem Did we ask for the current SID again?
    if /i "%OLD_ORACLE_SID%" EQU "NOT_SET" (
        goto :ask_me_again
    ) else (
        set NEW_SID=%OLD_ORACLE_SID%
    )

rem Get current PATH and fixup any double quoting that Control Panel
rem allows, but SETPATH=... does not. Consistency eh?
rem Makes sure that the remaining code uses the corrected path.
:tidy_path
    set NEW_HOME=
    set NEW_PATH=

    rem echo Calling TidyPath ....
    for /f "delims=" %%a in ('TidyPath %OLD_HOME%') do @set PATH=%%a
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo TidyPath error. %ERRORLEVEL% Please investigate.
        echo.
        goto :eof
    )   
   

rem Get Oracle Home for the new sid
    rem echo Calling DBHome %NEW_SID% ....
    for /f "delims=" %%a in ('DBHome %NEW_SID%') do @set NEW_HOME=%%a
    if "%NEW_HOME%" EQU "" (
        echo.
        echo Invalid SID supplied: %NEW_SID%
        echo.
        goto :eof
    )


rem Do we need to change PATH? We will always have to change it
rem if this is the first time that ORACLE_SID or ORACLE_HOME are
rem being set.
:set_new_path
    if "%OLD_ORACLE_SID%" EQU "NOT_SET" (
        rem No current settings, everything is new. Just add to path.
        set ORACLE_SID=%NEW_SID%
        set ORACLE_HOME=%NEW_HOME%

        rem This would have failed had we not corrected PATH above by
        rem double quoting the unquoted paths with "strange" characters.
        rem Without a setlocal, we can't use ORACLE_HOME or ORACLE_SID below
        rem as they take on their previous values. With a setlocal, we
        rem cannot change the variables in the caller. It's one or the other
        rem in this so called scripting language!
        set PATH=%NEW_HOME%\bin;%PATH%
        echo.
        goto :all_done
    )


rem We have an existing path which we need to adjust.
rem However, only if we didn't change the ORACLE_HOME path.
rem This copes with no change to the SID too.
:no_change
    if "%OLD_ORACLE_HOME%" EQU "%NEW_HOME%" (
        rem No change to HOME (or SID perhaps), so PATH is ok, just set SID.
        set ORACLE_SID=%NEW_SID%
        echo.
        goto :all_done
    )


rem So, we are here, we have to remove the old home from the path
rem and add in the new one.
rem Remove ORACLE_HOME\* from the path.
:remove_old_path
    rem Get the old path to be removed first.
    rem We don't care if it is invalid though.
    rem echo Calling DBHome %OLD_ORACLE_SID% ....
    for /f "delims=" %%a in ('DBHome %OLD_ORACLE_SID%') do @set OLD_HOME=%%a

    rem Now remove the old oracle home from the path - if it's valid.
    if "%OLD_HOME%" NEQ "" (
        echo Calling DBPath %OLD_HOME% ....
        for /f "delims=" %%a in ('DBPath %OLD_HOME%') do @set NEW_PATH=%%a
        if %ERRORLEVEL% NEQ 0 (
            echo.
            echo DBPath error. %ERRORLEVEL% Please investigate.
            echo.
            goto :eof
        )
    )

    rem And finally, add the new oracle home to the path.
    set ORACLE_SID=%NEW_SID%
    set ORACLE_HOME=%NEW_HOME%
    set OLD_PATH=%PATH%
    set PATH=%ORACLE_HOME%\bin;%NEW_PATH%
    echo.
    goto :all_done


rem Exit via here when we have changed something.
:all_done
    rem We always set these regardless.
    set NLS_DATE_FORMAT=yyyy/mm/dd hh24:mi:ss
    set NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1

    echo Environment set as follows:

rem Exit vis here to display current/new settings.    
:display_details
    set ORACLE_SID
    set ORACLE_HOME
    set NLS_DATE_FORMAT
    set NLS_LANG
    echo.
    
rem We must clean up after ourself.    
:clean_up
    set NEW_SID=
    set NEW_HOME=
    set NEW_PATH=
    set OLD_ORACLE_HOME=
    set OLD_ORACLE_PATH=    