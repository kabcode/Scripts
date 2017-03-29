@rem absolute path to lightroom installation
SET LRPATH="path\to\lightroom.exe"
SET CATALOGUE="name_of_your_catalogue.lrcat"

@rem files to sync on NAS
SET NASPATH="path\to\network\storage\location"
SET NASPREVIEWS="path\to\network\storage\location\Previews.lrdata"
SET NASSMARTPREVIEWS="path\to\network\storage\location\Smart Previews.lrdata"

@rem files to sync on PC
SET PCPATH="path\to\working\directory"
SET PCPREVIEWS="path\to\working\directory\Previews.lrdata"
SET PCSMARTPREVIEWS="path\to\working\directory\Smart Previews.lrdata"

@rem system call
@SETLOCAL EnableDelayedExpansion

@rem sync only if NAS catalogue newer than on PC
@CALL :joinpath %NASPATH% %CATALOGUE%
SET NASCATALOGUE=%RESULT%
@FOR %%i IN (%NASCATALOGUE%) DO SET DATE1=%%~ti
@CALL :joinpath %PCPATH% %CATALOGUE%
SET PCCATALOGUE=%RESULT%
@FOR %%i IN (%PCCATALOGUE%) DO SET DATE2=%%~ti
@IF "%DATE1%"=="%DATE2%" ECHO Files have same age && GOTO :END
FOR /F %%i IN ('DIR /B /O:D %NASCATALOGUE% %PCCATALOGUE%') DO SET NEWEST=%%~fi
ECHO Newer file is %NEWEST%
IF %NEWEST%==%PCCATALOGUE% CHOICE /M "The catalogue on PC is newer. Do you want to overwrite?"
IF %ERRORLEVEL%==1 GOTO :END
IF %ERRORLEVEL%==2 GOTO :EOF
:END

@rem syncing folders and files from NAS to Working folder on PC
@rem copy lightroom catalogue
ROBOCOPY %NASPATH% %PCPATH% %CATALOGUE% /NFL /NDL /Z /R:1

@rem copy existing smart previews
ROBOCOPY %NASSMARTPREVIEWS% %PCSMARTPREVIEWS% /NFL /NDL /XJ /Z /FFT /E /R:1 /W:10 /XA:H

@rem copy existing previews
ROBOCOPY %NASPREVIEWS% %PCPREVIEWS% /NFL /NDL /XJ /Z /FFT /E /R:1 /W:10 /XA:H

@rem working with lightroom with sync catalogue
@CALL :joinpath %PCPATH% %CATALOGUE%
START /b /wait "" %LRPATH% %RESULT%

@rem syncing folders and files from PC to storage folder on NAS after closing lightroom
@rem copy lightroom catalogue
ROBOCOPY %PCPATH% %NASPATH% %CATALOGUE% /NFL /NDL /Z /R:1

@rem copy existing smart previews
ROBOCOPY %PCSMARTPREVIEWS% %NASSMARTPREVIEWS% /NFL /NDL /XJ /Z /FFT /E /R:1 /W:10 /XA:H

@rem copy existing previews
ROBOCOPY %PCPREVIEWS% %NASPREVIEWS% /NFL /NDL /XJ /Z /FFT /E /R:1 /W:10 /XA:H

rem finish the file
GOTO :EOF

rem function to create paths
:joinpath
@SET PATH1=%~1
@SET PATH2=%~2
@IF {%PATH1:~-1,1%}=={\} (SET RESULT=%PATH1%%PATH2%) ELSE (SET RESULT=%PATH1%\%PATH2%)
@GOTO:EOF

:EOF