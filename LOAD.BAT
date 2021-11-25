@rem
@rem  Programming in DDS for Display and Printer Files.......
@rem
@echo.
@echo          Programming in DDS for Display and Printer Files 
@echo.
@echo          Starting procedure to load source onto hard drive.
@echo.
@echo.
@rem
@rem  1)  Determine which disk drive the user loaded the diskette......
@rem
@set drive=a:
@if %1.==.  goto setdir
@if %1==a:  goto setdir
@if %1==A:  goto setdir
@if %1==b:  set drive=b:
@if %1==B:  set drive=B:
@echo  Bad drive identifier.......try command again.
@echo.
@pause
@goto endpgm
@rem
@rem  2)  Create directory PRGDDS on C drive if not already there......
@rem
:setdir
@c:
@cd\
@set dirname=PRGDDS
@if not exist c:\prgdds\nul goto makedir
@echo.
@echo.
@echo  The directory PRGDDS already exists.  If you wish to continue
@echo  with the loading of this product, you must choose "Y" to overlay
@echo  the directory.  Overlaying the directory will wipe out everything
@echo  in that directory.
@echo.
@choice /c:yn Do you wish to overlay the directory
@if errorlevel 2 goto quit
@if errorlevel 1 goto removedir
:quit
@echo.
@echo  The upload of this product has been stopped.
@echo.
@pause
@goto endpgm
:removedir
@deltree /y c:\%dirname% > nul
:makedir
@mkdir %dirname%
@rem
@rem  3)  Copy all files from diskette to PRGDDS directory.............
@rem
:copyfiles
@cd\%dirname%
@echo.
@echo.
@echo Copying files to hard drive directory %dirname%.
@echo.
@copy %drive%\*.exe > nul
@copy %drive%\readme.txt > nul
@rem
@rem  4)  Expand all .EXE files........................................
@rem
@echo.
@echo.
@echo Running Self-Extracting files.
@echo.
@echo.
@prgdds.exe
@newsupld.exe
@echo.
@rem
@rem  5)  Copy VBRUN300.DLL to WINDOWS directory if not already there..
@rem
@if exist c:\windows\vbrun300.dll  goto skipdll
@copy vbrun300.dll c:\windows\*.* > nul
:skipdll
@rem
@rem  6)  Notify user that example programs ready for upload...........
@rem         (See README.TXT)..........................................
@rem
@cls
@type readme.txt | more
@echo.
@echo.
@pause
:endpgm
