@echo off
REM Import Order Checker (CI/CD Mode)
REM Usage: scripts\check_imports.bat [path] (defaults to lib)
REM Exit code 0: All imports are correctly ordered
REM Exit code 1: Import ordering issues found

if "%~1"=="" (
    set PATH_TO_CHECK=lib
) else (
    set PATH_TO_CHECK=%~1
)

echo 🔍 Import Order Checker (CI/CD Mode)
echo Checking imports in: %PATH_TO_CHECK%
echo.

dart run import_order_lint:import_order --set-exit-if-changed -v "%PATH_TO_CHECK%"

REM The exit code is already set by the Dart tool
REM 0 = all good, 1 = issues found 
