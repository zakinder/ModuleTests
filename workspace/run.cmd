%~d1
@echo off
del *.ucdb *.wlf *.log *.htm *.opt *.contrib *.noncontrib *.rank *.vstf
rd work /s /q
@REM rd ..\modules\doc\covhtmlreports\template_test /s /q
@REM rd ..\modules\doc\covhtmlreports\axiLite_test /s /q
@REM rd ..\modules\doc\covhtmlreports\rgb_test /s /q
@REM rd ..\modules\doc\covhtmlreports\SystemCoverage /s /q


:WHAT

@echo ------------------
@echo 1-rgb_test
@echo 2-axiLite_test
@echo 3-template_test
@echo 4-runAll
@echo 5-rgb_test Coverage Report
@echo 6-axiLite_test Coverage Report
@echo 7-template_test Coverage Report
@echo 8-AllMerged Coverage Report
@echo 9-CleanAll

@echo ------------------
@set /p Select=" CMD "
@if "%Select%"=="1" (@GOTO TEST1)
@if "%Select%"=="2" (@GOTO TEST2)
@if "%Select%"=="3" (@GOTO TEST3)
@if "%Select%"=="4" (@GOTO TEST4)
@if "%Select%"=="5" (@GOTO TEST1HTML)
@if "%Select%"=="6" (@GOTO TEST2HTML)
@if "%Select%"=="7" (@GOTO TEST3HTML)
@if "%Select%"=="8" (@GOTO TEST4HTML)
@if "%Select%"=="9" (@GOTO CLEAN_ALL)
@GOTO WHAT




:TEST1
vsim -c -do rgb_test.tcl
Powershell.exe -executionpolicy remotesigned -File rgb_test.ps1 
vsim -c -do rgb_test2.tcl
Powershell.exe -executionpolicy remotesigned -File rgb_test2.ps1 
@GOTO WHAT
:TEST2
vsim -c -do axiLite_test.tcl
Powershell.exe -executionpolicy remotesigned -File axiLite_test.ps1
@GOTO WHAT
:TEST3
vsim -c -do template_test.tcl
Powershell.exe -executionpolicy remotesigned -File template_test.ps1
@GOTO WHAT
:TEST4
vsim -c -do run.tcl
Powershell.exe -executionpolicy remotesigned -File SystemCoverage.ps1
@GOTO WHAT

:TEST1HTML
Powershell.exe -executionpolicy remotesigned -File rgb_test.ps1
@GOTO WHAT
:TEST2HTML
Powershell.exe -executionpolicy remotesigned -File axiLite_test.ps1
@GOTO WHAT
:TEST3HTML
Powershell.exe -executionpolicy remotesigned -File template_test.ps1
@GOTO WHAT
:TEST4HTML
Powershell.exe -executionpolicy remotesigned -File SystemCoverage.ps1
@GOTO WHAT

:CLEAN_ALL
del *.ucdb *.wlf *.log *.htm *.opt *.contrib *.noncontrib *.rank *.vstf *.txt transcript
rd work /s /q
rd ..\modules\doc\covhtmlreports\template_test /s /q
rd ..\modules\doc\covhtmlreports\axiLite_test /s /q
rd ..\modules\doc\covhtmlreports\rgb_test /s /q
rd ..\modules\doc\covhtmlreports\rgb_test2 /s /q
rd ..\modules\doc\covhtmlreports\SystemCoverage /s /q
@GOTO WHAT


:ABORT

:EOF
@REM @PAUSE

:GO_UP
cd ..\
@GOTO WHAT