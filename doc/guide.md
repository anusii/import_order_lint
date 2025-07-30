# Import Order Management Guide

This guide explains how to use the import_order_lint package for both development and CI/CD pipelines.

## 🎯 Quick Start

### Check Import Ordering (CI/CD Mode)
```bash
# Using convenience scripts
scripts/check_imports.sh    # Linux/macOS
scripts/check_imports.bat   # Windows

# Direct command 
dart run import_order_lint:import_order --set-exit-if-changed
```

### Fix Import Ordering (Development Mode)
```bash
# Using convenience scripts
scripts/fix_imports.sh      # Linux/macOS  
scripts/fix_imports.bat     # Windows

# Direct command
dart run import_order_lint:import_order
```

## 📋 Available Scripts

### Development Scripts (Will Modify Files)
- `scripts/fix_imports.sh` / `scripts/fix_imports.bat` - Automatically fixes import ordering
- ⚠️ **Warning**: These scripts modify your source files

### CI/CD Scripts (Check Only)
- `scripts/check_imports.sh` / `scripts/check_imports.bat` - Checks import ordering without modifying files
- ✅ **Exit Code 0**: All imports are correctly ordered
- ❌ **Exit Code 1**: Import ordering issues found (fails CI/CD build)

## 🔧 Command Line Options

### Basic Usage
```bash
dart run import_order_lint:import_order [options] [paths]
```

**Key Features:**
- **Auto-detects project name** from `pubspec.yaml` 
- **Defaults to `lib` directory** if no paths specified
- **Recursive by default** for directories

### Options
- `-h, --help` - Show help information
- `-v, --verbose` - Show detailed output
- `-c, --check` - Check mode (don't fix, just report issues)
- `--set-exit-if-changed` - Return exit code 1 if imports would be changed (like `dart format`)
- `--dry-run` - Same as --check
- `--project-name=NAME` - Explicitly set project name

### Examples
```bash
# Fix imports in lib directory (default behavior)
dart run import_order_lint:import_order

# Check without fixing (CI/CD mode)
dart run import_order_lint:import_order --set-exit-if-changed

# Fix specific directories
dart run import_order_lint:import_order lib test

# Fix single file
dart run import_order_lint:import_order lib/main.dart

# Verbose output
dart run import_order_lint:import_order --set-exit-if-changed -v

# Explicit project name (if auto-detection fails)
dart run import_order_lint:import_order --project-name=myproject
```

## 🚀 CI/CD Integration

### GitHub Actions
```yaml
name: Code Quality Check

on: [push, pull_request]

jobs:
  code-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - name: Get dependencies
        run: dart pub get
      - name: Check code formatting
        run: dart format --set-exit-if-changed .
      - name: Check import ordering  
        run: dart run import_order_lint:import_order --set-exit-if-changed
      - name: Run static analysis
        run: dart analyze
```

### GitLab CI
```yaml
import_order_check:
  stage: test
  script:
    - dart pub get
    - dart run import_order_lint:import_order --set-exit-if-changed
```

### Azure DevOps
```yaml
- task: Bash@3
  displayName: 'Check Import Ordering'
  inputs:
    targetType: 'inline'
    script: |
      dart pub get
      dart run import_order_lint:import_order --set-exit-if-changed
```

## 📐 Import Ordering Rules

The tool enforces the following import order:

1. **Dart SDK imports** (`dart:*`)
   ```dart
   import 'dart:async';
   import 'dart:io';
   ```

2. **Flutter imports** (`package:flutter/*`)
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter/services.dart';
   ```

3. **External package imports** (other `package:*`)
   ```dart
   import 'package:http/http.dart';
   import 'package:path/path.dart';
   ```

4. **Project imports** (`package:myproject/*`)
   ```dart
   import 'package:myproject/models/user.dart';
   import 'package:myproject/utils/constants.dart';
   ```

5. **Relative imports**
   ```dart
   import '../models/movie.dart';
   import './utils.dart';
   ```

### Requirements
- **Alphabetical sorting** within each group
- **Blank lines** between different import groups
- **No blank lines** within the same group

## 🔄 Development Workflow

### For Developers
1. **Write code** with imports in any order
2. **Before committing**: Run `dart run import_order_lint:import_order` to auto-fix ordering
3. **Commit** the properly ordered imports

### Pre-commit Hook (Optional)
```bash
#!/bin/sh
# .git/hooks/pre-commit
echo "Checking import ordering..."
dart run import_order_lint:import_order --set-exit-if-changed
if [ $? -ne 0 ]; then
    echo "❌ Import ordering issues found!"
    echo "Run 'dart run import_order_lint:import_order' to fix them."
    exit 1
fi
echo "✅ Import ordering is correct."
```

## 🐛 Troubleshooting

### Common Issues

**Q: Tool says "Project name not found"**
A: Use `--project-name=myproject` explicitly

**Q: CI/CD fails with import errors**
A: Run `dart run import_order_lint:import_order` locally, then commit the fixes

**Q: Want to see what would be fixed**
A: Use `--dry-run` or `--check` with `-v` for verbose output

### Exit Codes
- **0**: Success (no issues or fixes applied successfully)
- **1**: Issues found (in check mode) or processing errors

## 🎯 Best Practices

### For Development
- ✅ Run `dart run import_order_lint:import_order` before committing
- ✅ Use your IDE's organize imports feature as a first step
- ✅ Set up your IDE to auto-organize imports on save

### For CI/CD
- ✅ Use `dart run import_order_lint:import_order --set-exit-if-changed` in your pipeline
- ✅ Run check early in the pipeline (fast feedback)
- ✅ Make import order check a required status check
- ✅ Include helpful error messages for developers

### Team Workflow
- ✅ Include import ordering in code review checklist
- ✅ Document this process in team onboarding
- ✅ Consider adding pre-commit hooks for automatic checking

## 🔗 Related Tools

This tool works well with:
- `dart format` - Code formatting
- `dart analyze` - Static analysis
- `flutter_lints` - Official Flutter linting rules
- IDE import organization features 