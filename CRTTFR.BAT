@echo off
::=====================================================================
:: CRTTFR.BAT
:: This batch file creates a PCS .TFR file and, optionally, runs
:: the RFROMPCB program. It allows dynamic file substitution
:: into the PCS .TFR file.
::
:: From "Batch File Basics, Part 3,"  NEWS 3X/400, November 1993
::
:: This batch file expects program rfrompcb to be in a directory in the
:: DOS path.
::
:: COPYRIGHT (c) 1993 Duke Communications International,
:: ALL RIGHTS RESERVED.  This program may not be reproduced
:: or distributed in any form without permission in writing
:: from the publisher, except for noncommercial, private use
:: and adaptation granted by U.S. copyright law.
:: Redistribution of this program, or the distribution of
:: derivative works, is expressly prohibited.  This copyright
:: notice must remain in all private-use copies.
::=====================================================================
:: Parameters
:: %1 The name of the pc file
:: %2 The name of the host file 
:: %3 The name of the .TFR file to be created
:: %4 The name of an existing .FDF file -- required for data files -- or
::    Run the request -- optional
:: %5 Run the request -- optional
::=====================================================================
:: Example Usage
:: CRTTFR.TFR member1.clp mikeo/qclsrc(member1) temp.tfr run
:: ====================================================================
:: Check for the required parameters
if "%1"=="" goto USAGE
if "%2"=="" goto USAGE
if "%3"=="" goto USAGE 

:: Initialize variables
set FDF=NO
set RUN=NO

:: Check the optional parameters
:: If %4 is blank, there are no optional parameters
if "%4"=="" goto TFR

:: Parameter %4 was specified, but it was not "RUN", "run", or an FDF file
if not "%4"=="RUN" if not "%4"=="run" if not exist %4 goto USAGE

:: If parameter %4 was a valid file, set FDF variable
if exist %4 set FDF=YES
if exist %4 goto PARM5

:: If parameter %4 was "RUN" or "run", set the RUN variable and build the TFR file
set RUN=YES
goto TFR

:PARM5
if "%5"=="" goto TFR
:: If parameter %5 is specified, it must be "RUN or "run"
if not "%5"=="RUN" if not "%5"=="run" goto USAGE
set RUN=YES

:TFR
:: Create the TFR file
echo TRFRPC>%3
echo Created by CRTTFR.BAT>>%3
echo TO          %2>>%3
echo %1>>%3
if "%FDF%"=="YES" echo 11>>%3
if "%FDF%"=="NO"  echo 21>>%3
if "%FDF%"=="YES" echo %4>>%3
if "%FDF%"=="NO"  echo "">>%3
echo 32    1>>%3
echo "">>%3
echo "">>%3
echo "">>%3
echo SYSTEM>>%3
echo The transfer file %3 has been created

:: Check to run the RFROMPCB program
if "%RUN%"=="NO" goto END
rfrompcb %3
if errorlevel 20 goto FROMPCERROR
echo Transfer from %1 to %2 has completed!
goto END

:USAGE
echo Usage: CRTTFR pcfile.ext hostfile tfrfile.tfr [fdfile.fdf] [run]
goto END

:FROMPCERROR
echo There was an error running the transfer request

:END
::release environment storage for variables
set FDF=
set RUN=
