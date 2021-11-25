@echo off
:: Batch file:  DOSUP.BAT
::
:: This DOS batch file uploads and compiles the code included in a
:: NEWS 3X/400 bundle (.BDL) file.
::
:: This program reads the command line for the location of the 
:: bundle file and its name, as well as a name of a NON-EXISTING
:: work file and source file to contain the bundle file and the
:: source code, respectively.
::
:: Command line parameters:
:: %1 Path and name of the bundle file (e.g., N949133.BDL)
:: %2 Library name to contain the bundle file and the unbundled
::    source code.
:: %3 Work file that will contain the bundle file.  
::    NOTE: This file will be created by this utility, so it must
::          not exist when this utility runs.
:: %4 Source file that will contain the unbundled source code.
::    NOTE: This file will be created by this utility, so it must
::          not exist when this utility runs.
::
:: Examples of running this program:
::
::    dosup \sep\n949133.bdl mylib n949133b n949133l
::    The above does the following:
::      1. creates a file called N949133 in library MYLIB, 
::      2. copies PC file N949133.BDL to it, 
::      3. creates source file N949133L in library MYLIB,
::      4. unbundles N949133B and stores the source in file N949133,
::      5. compiles the source in N949133L according to the compile
::         instructions in the bundle file.

    ::Check for required parameters
    if "%1"==""         goto usage
    if "%2"==""         goto usage
    if "%3"==""         goto usage
    if "%4"==""         goto usage

    if not exist %1     goto nofile

    echo -------------------------------------------------------------------------
    echo Create file %2/%3
    echo -------------------------------------------------------------------------

    rmtcmd CRTPF FILE(%2/%3) RCDLEN(100)
    if errorlevel 20 goto BUILDERROR

    echo -------------------------------------------------------------------------
    echo Transfer bundle file %1 to %2/%3
    echo -------------------------------------------------------------------------

    echo PCFDF>BUNDLE.FDF
    echo PCFT 1 ASCII text>>BUNDLE.FDF
    echo PCFL %3 1 100>>BUNDLE.FDF
    echo >>BUNDLE.FDF
    call crttfr %1 %2/%3 temp.tfr bundle.fdf run
    if errorlevel 20 goto XFRERROR

    echo -------------------------------------------------------------------------
    echo Create source file %2/%4
    echo -------------------------------------------------------------------------

    rmtcmd CRTSRCPF FILE(%2/%4) RCDLEN(92)
    if errorlevel 20 goto BUILDERROR

    echo -------------------------------------------------------------------------
    echo Submit AS/400 batch job to unbundle and compile bundle file %2/%3
    echo -------------------------------------------------------------------------

    rmtcmd SBMJOB CMD(UNBUNDLE BUNDLE(%2/%3) SRCFILE(%2/%4))
    if errorlevel 20 goto COMPERROR
    goto END

::Errors --------------------------------------------------------------------------

:USAGE
    echo ***************************************************************************
    echo *                                                                         *
    echo * DOSUP pc-bundle-file host-library host-bundle-file host-source-file     *
    echo *                                                                         *
    echo * where                                                                   *
    echo *                                                                         *
    echo * pc-bundle-file                                                          *
    echo * Path and name of the bundle file (e.g., N949133.BDL).                   *
    echo *                                                                         *
    echo * host-library                                                            *
    echo * Library name to contain host-bundle-file and host-source-file           *
    echo *                                                                         *
    echo * host-bundle-file                                                        *
    echo * Physical file that will contain the uploaded bundle file.               *
    echo *                                                                         *
    echo * host-source-file                                                        *
    echo * Source file that will contain the article source members.               *
    echo *                                                                         *
    echo * An example of calling DOSUP is:                                         *
    echo *                                                                         *
    echo *    dosup \sep\n949133.bdl mylib n949133b n949133l                       *
    echo *                                                                         *
    echo ***************************************************************************
    goto END

:NOFILE
    echo File %1 not found
    goto END

:BUILDERROR
    echo There was an error creating file %2/%3
    goto END

:XFRERROR
    echo There was an error transfering file %1 to the AS/400
    goto END

:COMPERROR
    echo There was an error unbundling and compiling bundle file %2/%3
    goto END

:END
   if exist temp.tfr    del temp.tfr
   if exist bundle.fdf  del bundle.fdf
