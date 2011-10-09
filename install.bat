@echo off

SET HOME=%USERPROFILE%
SET SRCDIR=%~dp0
SET MODULE=%~n0
@rem /L to test the command (dry run, no copy).
@REM SET DRYRUN=/L 

@rem options are :
@rem /s for subfolders.
@rem /xn to prevent overwriting newer files.
@rem /xf exclude specific files.
robocopy %SRCDIR% %HOME% %DRYRUN% /s /xn /xf README.rst /xf "*.swp" /xd .git /xf %MODULE%.* /LOG:%MODULE%.log
if errorlevel 4 goto handle_error

goto end

:handle_error
echo Robocopy exit code %ERRORLEVEL%. See %MODULE%.log for details. 1>&2
@rem /b prevents the calling script (if any) to bail with the exit command.
exit /b 1

:end
@rem /b prevents the calling script (if any) to bail with the exit command.
exit /b 0

