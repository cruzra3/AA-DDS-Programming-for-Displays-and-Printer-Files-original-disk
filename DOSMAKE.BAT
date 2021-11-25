@echo off
:: Batch file:  DOSMAKE.BAT
::
:: This program uploads and compiles the NEWS 3X/400 Utility MAKE facility.
::
:: The utility is comprised of four programs: 
::    Command UNBUNDLE
::    RPG program UNBUNDLER
::    COBOL program UNBUNDLEC (performs the same function as UNBUNDLER)
::    CL program UNBUNDLEZ
::
:: The Utility MAKE facility processes NEWS 3X/400 bundle (.BDL) files, which
:: contain source code from published articles, as well as the instructions
:: necessary to compile the source code. 
::
:: Command line parameters:
:: %1 PC directory containing the MAKE facility
:: %2 Host library to contain the MAKE facility
:: %3 Host source physical file to contain the MAKE facility
::    NOTE: This file will be created by this utility, so it must
::          not exist when this utility runs.
:: %4 Specifies whether the RPG or COBOL version of the UNBUNDLE program should be used

    ::Check for required parameters
    if "%1"==""         goto usage
    if "%2"==""         goto usage
    if "%3"==""         goto usage
    if "%4"==""         goto usage

    echo -------------------------------------------------------------------------
    echo Create source file %2/%3
    echo -------------------------------------------------------------------------

    rmtcmd CRTSRCPF FILE(%2/%3) RCDLEN(92)
    if errorlevel 20 goto CREATERROR

    echo -------------------------------------------------------------------------
    echo Uploading and compiling the UNBUNDLE command
    echo -------------------------------------------------------------------------

    us /cvttab %1\unbundle.cmd %2/%3(unbundle) "NEWS 3X/400 Utility Make Facility"
    If errorlevel 20 goto MAKEERROR

    rmtcmd CRTCMD CMD(%2/unbundle) PGM(%2/unbundle) SRCFILE(%2/%3)
    If errorlevel 20 goto BUILDERROR

    echo -------------------------------------------------------------------------
    echo Uploading and compiling the UNBUNDLE program
    echo -------------------------------------------------------------------------

    if "%3"=="COBOL" goto COBOL
    us /cvttab %1\unbundle.rpg %2/%3(unbundler) "NEWS 3X/400 Utility Make Facility"
    If errorlevel 20 goto MAKEERROR

    rmtcmd CRTRPGPGM PGM(%2/unbundle) SRCFILE(%2/%3) SRCMBR(unbundler)
    If errorlevel 20 goto BUILDERROR
    goto NEXTCMD

:COBOL
    us /cvttab %1\unbundle.cbl %2/%3(unbundlec) "NEWS 3X/400 Utility Make Facility"
    If errorlevel 20 goto MAKEERROR

    rmtcmd CRTRPGPGM PGM(%2/unbundle) SRCFILE(%2/%3) SRCMBR(unbundlec)
    If errorlevel 20 goto BUILDERROR

:NEXTCMD
    echo -------------------------------------------------------------------------
    echo Uploading and compiling the UNBUNDLEZ CL program 
    echo -------------------------------------------------------------------------
 
    us /cvttab %1\unbundle.clp %2/%3(unbundlez) "NEWS 3X/400 Utility Make Facility"
     If errorlevel 20 goto MAKEERROR

    rmtcmd CRTCLPGM PGM(%2/unbundlez) SRCFILE(%2/%3)
    If errorlevel 20 goto BUILDERROR

    echo -------------------------------------------------------------------------
    echo Finished creating the NEWS 3X/400 Utility MAKE facility 
    echo -------------------------------------------------------------------------
    goto END

::Errors --------------------------------------------------------------------------

:USAGE
    echo ***************************************************************************
    echo *                                                                         *
    echo * DOSMAKE pc-directory host-library host-source-file host-compiler        *
    echo *                                                                         *
    echo * where:                                                                  *
    echo *                                                                         *
    echo * pc-directory                                                            *
    echo * Contains UNBUNDLE.CLP, UNBUNDLE.CMD, UNBUNDLE.RPG, and UNBUNDLE.CBL.    *
    echo *                                                                         *
    echo * host-library                                                            *
    echo * AS/400 library to contain the MAKE facility.                            *
    echo *                                                                         *
    echo * host-source-file                                                        *
    echo * AS/400 source file to contain MAKE facility programs.                   *
    echo *                                                                         *
    echo * host-compiler                                                           *
    echo * RPG  = RPG version of the MAKE facility will be uploaded and compiled.  *
    echo * COBOL= COBOL version will be uploaded and compiled.                     *
    echo *                                                                         *
    echo * An example of calling DOSMAKE is:                                       *
    echo *                                                                         *
    echo *   DOSMAKE \news mylib mysource RPG                                      *
    echo *                                                                         *
    echo ***************************************************************************
    goto END

:CREATERROR
    echo There was an error building the source physical file %2/%3
    goto END

:MAKEERROR
    echo There was an error transfering one of the MAKE programs to the AS/400
    goto END

:BUILDERROR
    echo There was an error compiling on of the MAKE programs on the AS/400
    goto END

:END
