@echo off
rem =================================================================
rem Build some docs. Translates an RST into DOCX and PDF.
rem =================================================================
rem pass the root of the document on the command line.
rem
rem     buildDocs fred[.rst] [Latex Colour name]
rem     builddocs help
rem
rem Takes 'fred.rst' and creates 'fred.pdf'. The .rst is assumed and
rem is optional.                     
rem
rem Norman Dunbar
rem 23 March 2017.
rem =================================================================

rem Have to initialise or Windows remembers stuff!
setlocal
echo.

rem Assume it will work.
set RESULT=0

rem Get the document name from the command line.
set DOCUMENT=%1
if "%DOCUMENT%" equ "" (
    echo No DOCUMENT name supplied.
    echo USAGE: BuildDocs Filename[.rst]
    exit/b 1
)

rem Get the optional colour name from the command line.
set COLOUR=%2

rem See :help_me at the end for colour dretails.

rem Help?
if /i "%DOCUMENT%" EQU "HELP" (
    goto :help_me
)

rem Colour names are case dependent, so don't go changing!
rem Americans can't spell grey properly, so if I happen to use
rem the correct spelling, make it wrong. Also, white link colours?
rem Not going to work on a white paper background, so amend to
rem lightgrey instead - the closest visible colour.
if "%COLOUR%" EQU "" (
    set COLOUR=blue
    goto :got_colour
)

rem check if we got a silly colour or not.
rem Windows doesn't really do nested IF's very well.
if "%COLOUR%" equ "lightgrey" (
    rem Have to keep the Americans happy!
    rem Standard Latex colour.
    echo Sorry, have to change 'lightgrey' to 'lightgray' to keep xcolor happy!
    set COLOUR=lightgray
    goto :got_colour
)

if "%COLOUR%" equ "darkgrey" (
    rem Have to keep the Americans happy!
    rem Standard Latex colour.
    echo Sorry, have to change 'darkgrey' to 'darkgray' to keep xcolor happy!
    set COLOUR=darkgray
    goto :got_colour
)

if "%COLOUR%" equ "Grey" (
    rem Have to keep the Americans happy!
    rem Standard DIVPS colour.
    echo Sorry, have to change 'Grey' to 'Gray' to keep xcolor happy!
    set COLOUR=Gray
    goto :got_colour
)

if "%COLOUR%" equ "CoolGray" (
    rem Have to keep the Brits happy!
    rem Standard Latex colour.
    echo Sorry, have to change 'CoolGray' to 'CoolGrey' to keep xcolor happy!
    set COLOUR=CoolGrey
    goto :got_colour
)

if /i "%COLOUR%" equ "white" (
    rem Filter out the daft people! ;-)
    rem Standard Latex colour (white) or divps (White)
    echo White link colour requested. This won't show up on paper!
    echo Changed 'white' to 'lightgray' which is the closest visible colour. 
    set COLOUR=lightgray
    goto :got_colour
)     

rem We have a colour name, set it.
:got_colour    
set TOCCOLOUR="%COLOUR%"
set LINKCOLOUR="%COLOUR%"
set URLCOLOUR="%COLOUR%"

rem Really Windows? Really!
rem There has to be a better way. (There is, Linux!)
rem Strip off the extension, we assume that it's '.rst'.
for /F %%A in ("%DOCUMENT%") do (
    @set DOCUMENT=%%~nA
)


echo Building %DOCUMENT%.pdf from %DOCUMENT%.rst - please wait ....
echo Link colours will be %COLOUR% ...
echo.


rem Build a pdf file. 
pandoc -f rst -t latex -o %DOCUMENT%.pdf --toc --toc-depth=3 %DOCUMENT%.rst --variable fontfamily="utopia" --listings -H listings_setup.tex --variable toccolor="%TOCCOLOUR%" --variable linkcolor="%LINKCOLOUR%" --variable urlcolor="%URLCOLOUR%" --variable margin-top=2.5cm --variable margin-left=2.5cm --variable margin-right=2.5cm --variable margin-bottom=3.5cm

set RESULT=%ERRORLEVEL%

rem Exit if no errors.
if "%RESULT%" EQU "0" (
    echo Done.
    goto :all_done
)

rem Try to determine what went wrong.

echo Build error %RESULT%. PDF not built.
echo.

rem Can't find pandoc.
if "%RESULT%" EQU "9009" (
    echo Error 9009: Is PANDOC on your path?
    goto :all_done
)

rem Propbably an invalid colour name used.
if "%RESULT%" EQU "43" (
    echo Error 43: Suspect an invalid Latex colour name has been specified. Try 'blue'.
    goto :all_done
)

rem Probably PDF file open in a reader.
if "%RESULT%" EQU "1" (
    echo Is %1.pdf open in a PDF Reader utility?
) 

rem I give up!
echo Unknown error.

rem Exit via here normally.
:all_done
endlocal

echo.

exit/b %RESULT%

rem Give me help!
:help_me
echo.
echo USAGE: BuildDocs filename[.rst] [Latex colour name]
echo.
echo Builds a PDF using Latex as intermediary, from an RST file.
echo Link colours are defaulted to Blue, as defined in listings_setup.tex
echo but can be changed by passing a different colour name as the second parameter.
echo.
echo Valid colour names are only:
echo.
echo Those defined in listings_setup.tex, which are:
echo.
echo    Cobalt
echo    CommentGreen (50% green.)
echo    CoolGrey
echo    Lava (A nice red.)
echo.
echo Colour names with spaces, are not permitted.
echo.
echo Other colour names permitted are the standard Latex colours
echo and the standard DIVPS colours. These are as follows, where the
echo standard Latex colours are in lower case and may duplicate 
echo some of the standard DIVPS colours.
echo.
echo    A: Apricot, Aquamarine, 
echo    B: Bittersweet, Black, black, Blue, blue, BlueGreen, 
echo       BlueViolet, BrickRed, Brown, brown,  BurntOrange, 
echo    C: CadetBlue, CarnationPink, Cerulean, CornflowerBlue, 
echo       Cyan, cyan, 
echo    D: Dandelion, darkgray, darkgray, DarkOrchid, 
echo    E: Emerald, 
echo    F: ForestGreen, Fuchsia, 
echo    G: Goldenrod, Gray, gray, Grey, Green, green, GreenYellow, 
echo    H:
echo    I:
echo    J: JungleGreen, 
echo    K:
echo    L: Lavender, lightgray, lightgrey, LimeGreen, lime, 
echo    M: Magenta, magenta, Mahogany, Maroon, Melon, 
echo       MidnightBlue, Mulberry, 
echo    N: NavyBlue, 
echo    O: olive, OliveGreen, Orange, orange, OrangeRed, Orchid, 
echo    P: Peach, Periwinkle, PineGreen, pink, Plum, ProcessBlue, 
echo       Purple, purple, 
echo    Q:
echo    R: RawSienna, Red, red, RedOrange, RedViolet, Rhodamine, 
echo       RoyalBlue, RoyalPurple, RubineRed, 
echo    S: Salmon, SeaGreen, Sepia, SkyBlue, SpringGreen, 
echo    T: Tan, teal, TealBlue, Thistle, Turquoise, 
echo    U:
echo    V: Violet, violet, VioletRed, 
echo    W: White, white, WildStrawberry, 
echo    X:
echo    Y: Yellow, yellow, YellowGreen, YellowOrange, 
echo    Z:
echo.
echo I've also allowed grey, lightgrey and darkgrey for those
echo of us who know how to spell English words correctly!
echo.
echo The 68 (currently) pre-defined DIVPS colours are all listed,
echo and demonstrated, at:
echo.
echo https://en.wikibooks.org/wiki/LaTeX/Colors#The_68_standard_colors_known_to_dvips
echo.
echo Colour names are CASE DEPENDENT - 'SkyBlue' does not equal 'skyblue'.
echo.   

exit/b 0
