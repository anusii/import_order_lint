@echo off
REM Import Order Fixer (FIX MODE)
REM Usage: scripts\fix_imports.bat [path] (defaults to lib)
REM This script WILL modify your files to fix import ordering

if "%~1"=="" (
    set PATH_TO_FIX=lib
) else (
    set PATH_TO_FIX=%~1
)

echo 🔧 Import Order Fixer (FIX MODE)
echo Fixing imports in: %PATH_TO_FIX%
echo ⚠️  This will modify your files!
echo.

dart run import_order_lint:import_order -v "%PATH_TO_FIX%"

echo.
echo ✅ Import fixing complete!
pause 
