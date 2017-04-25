# Oraenv for Windows

## Introduction
See the README.pdf file in the ``\Doc`` folder for full details, but ...

``Oraenv`` for Windows provides Windows Oracle DBAs (and developers etc) with an environment setup tool which resembles, *almost* 100%, the utility of the same name supplied on Unix systems.

``Oraenv`` for Windows will set the following environment variables according to definitions in an ``ORATAB`` text file:

- ORACLE_SID
- ORACLE_HOME
- PATH

In addition, it will default the following:

- NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
- NLS_DATE_FORMAT=yyyy/mm/dd hh24:mi:ss

## What it Does
If you already have an Oracle environment set up in your shell/batch session, then ``oraenv`` will, on changing the ``ORACLE_SID``:

- Set the correct ``ORACLE_HOME`` for the passed ``ORACLE_SID``;
- Clear down the previous ``ORACLE_HOME`` folder & sub-folders from ``PATH``;
- Add the (new) ``%ORACLE_HOME%``\\bin folder to ``PATH`` after *removing* the previous ``%ORACLE_HOME%``\\bin etc from the path.

In this manner, you will not end up with a mix and match of numerous different Oracle versions - which is usually unhealthy.

## Prompting for a SID
If you set ``ORAENV_ASK`` to YES (letter case is not significant), then running ``oraenv`` with no parameters will prompt you to enter a valid ``ORACLE_SID`` that can be found in the ``ORATAB`` file. Passing a new ``ORACLE_SID`` on the command line will not prompt, and will merely set the new environment to suite the passed ``ORACLE_SID``.

If ``ORAENV_ASK`` is not defined, or does not equal YES, then running ``oraenv`` with no parameters will simply display the current environment with no changes made.

## What You Get
The following files should be copied to a folder that is on your ``%PATH``%:

- **oraenv.cmd** - the main batch file. This is what you call to set the new Oracle environment.
- **DBHome.exe** - a utility to extract an ``ORCALE_HOME`` from an ``ORATAB`` file, for a given ``ORACLE_SID``. This is called from ``oratab.cmd`` to do the necessary work.
- **DBPath.exe** - a utility to remove all folders and sub-folders from ``%PATH%`` based on a passed parameter. This is used to remove the current Oracle Environment's paths from ``%PATH%`` before setting ``%PATH%`` with a new Oracle Environment. This is called from ``oratab.cmd`` to do the necessary work.
- **TidyPath.exe** - a utility that corrects the inconsistent behaviour of batch files when setting a new value for ``%PATH%`` where that new value contains characters that *confuse* the ``set`` command. These characters are valid when setting up ``%PATH%`` in Control Panel, but cause errors in batch files when used with ``set``. Consistency does not appear to be being considered here! 

    This utility reads the current ``%PATH%`` settings and for each folder detected, will wrap it in double quotes if it is not already wrapped and if it has any of the special characters in it which confuse the ``set`` command in batch files. ``TidyPath`` is called from ``oratab.cmd`` to do the necessary work.

## The Oratab File
The oratab file is the central hub on ``oraenv`` for Windows, as indeed it is on Unix systems. However, the format is slightly different from that on Unix as the colon used as a separator there, cannot be used on Widows as it is used as part of a drive specifier. We use the pipe character instead (|).

In addition, comments are allowed and are prefixed by a hash/pound/number character (#). Comments are allowed in the entry lines for each ``%ORACLE_SID%`` but these are specified by "|#" and can only appear *after* the ``ORACLE_HOME`` in the ``ORATAB`` file.

The file is searched for in the following locations:

- As defined by the ``%ORATAB%`` environment variable. This must be the full path and filename that is in use. For example, ``set ORATAB=c:\Oracle\oratab.txt``.  
- As the file ``oratab.txt`` in the location defined by the ``%ORACLE_BASE%`` environment variable, if it is defined.
- As the file named ``oratab.txt`` in the same folder as the ``DBHome.exe`` file.

### Example Oratab
The following is an example of an ``ORATAB`` file:

````
# OraTab file for use with oraenv for Windows.
#
# Clients:
#
client_32 | c:\Oracle\11.2\client_32 |# Oracle 11204 32 bit client
client_64 | c:\Oracle\11.2\client_64 |# Oracle 11204 64 bit client
#
# Databases
#
prod | c:\Oracle\product\11.2.0.4\rdbms\dbhome_1
rmancat | c:\Oracle\product\11.2.0.4\rdbms\dbhome_1
oldprod | c:\Oracle\product\11.2.0.2\rdbms\dbhome_3 |# To be decommissioned
````  

## Installing
All you need to do is download the code etc from github (https://github.com/NormanDunbar/OraenvWin) and copy the files in the ``\bin\Release`` folder to somewhere on your ``%PATH%``. You will need the 4 files listed above.

Once the binaries have been installed/copied, all you need to do is set up a valid ``ORATAB`` file and set the ``ORATAB`` environment variable, preferably in Control Panel so that it is available for all users on the server, and you are good to go. All that is required is to add your database SIDs and HOMEs to the ``ORATAB`` file and the system will be usable.

See the ``README.pdf`` file in the ``\Doc`` folder for full details.

Enjoy.
