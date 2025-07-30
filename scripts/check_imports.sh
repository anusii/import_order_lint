#!/bin/bash
# Import Order Checker (CI/CD Mode)
# Usage: ./scripts/check_imports.sh [path] (defaults to lib)
# Exit code 0: All imports are correctly ordered
# Exit code 1: Import ordering issues found

PATH_TO_CHECK=${1:-lib}

echo "🔍 Import Order Checker (CI/CD Mode)"
echo "Checking imports in: $PATH_TO_CHECK"
echo ""

dart run import_order_lint:import_order --set-exit-if-changed -v "$PATH_TO_CHECK"

# The exit code is already set by the Dart tool
# 0 = all good, 1 = issues found 
