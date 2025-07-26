#!/bin/bash
# Import Order Fixer (FIX MODE)
# Usage: ./scripts/fix_imports.sh [path] (defaults to lib)
# This script WILL modify your files to fix import ordering

PATH_TO_FIX=${1:-lib}

echo "🔧 Import Order Fixer (FIX MODE)"
echo "Fixing imports in: $PATH_TO_FIX"
echo "⚠️  This will modify your files!"
echo ""

dart run import_order_lint:import_order -v "$PATH_TO_FIX"

echo ""
echo "✅ Import fixing complete!" 