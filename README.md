[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![GitHub License](https://img.shields.io/github/license/anusii/import_order_lint)](https://raw.githubusercontent.com/anusii/import_order_lint/main/LICENSE)
[![GitHub Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/anusii/import_order_lint/master/pubspec.yaml&query=$.version&label=version&logo=github)](https://github.com/anusii/import_order_lint/blob/dev/CHANGELOG.md)
[![Pub Version](https://img.shields.io/pub/v/import_order_lint?label=pub.dev&labelColor=333940&logo=flutter)](https://pub.dev/packages/import_order_lint)
[![GitHub Last Updated](https://img.shields.io/github/last-commit/anusii/import_order_lint?label=last%20updated)](https://github.com/anusii/import_order_lint/commits/main/)
[![GitHub Commit Activity (main)](https://img.shields.io/github/commit-activity/w/anusii/import_order_lint/main)](https://github.com/anusii/import_order_lint/commits/main/)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/import_order_lint)](https://github.com/anusii/import_order_lint/issues)

# Import Order Lint

An import ordering tool for Dart and Flutter projects that enforces
consistent import organization following the [Flutter Style
Guide](https://survivor.togaware.com/gnulinux/flutter-style-imports.html).

The package is published on [pub.dev](https://pub.dev/packages/import_order_lint).

## Features

- 🔧 **Enforces consistent import ordering** across your Dart/Flutter project
- 📚 **Groups imports into categories**:
  1. Dart SDK imports (e.g., 'dart:core', 'dart:async')
  2. Flutter imports (packages starting with 'package:flutter/')
  3. External package imports (other 'package:' imports)
  4. Project imports (package imports for your project)
  5. Relative imports (relative path imports)
- 🎨 **Alphabetical sorting** within each group
- 📏 **Proper spacing** - Blank lines between different import groups
- 🔍 **Auto-detection** - Automatically detects project name from `pubspec.yaml`
- 📁 **Smart defaults** - Defaults to `lib` directory, recursive by default
- ✅ **CI/CD ready** - Exit codes for automated pipelines

## Installation

Install a global executable `import_order`:

```bash
dart pub global activate import_order_lint
```

Or add the package to your `pubspec.yaml`:

```yaml
dev_dependencies:
  import_order_lint: ^0.2.0
```

## 🎯 Quick Start

```bash
# Fix import ordering
dart run import_order_lint:import_order

# Check import ordering (CI/CD mode)
dart run import_order_lint:import_order --set-exit-if-changed
```

**Auto-detects your project**, **defaults to lib directory**, and **provides proper CI/CD exit codes**!

## Usage

### 🔧 **Development Mode** (Fix imports)
```bash
# Fix lib directory (default)
dart run import_order_lint:import_order

# Fix specific directories
dart run import_order_lint:import_order lib test

# Fix single file
dart run import_order_lint:import_order lib/main.dart
```

### ✅ **CI/CD Mode** (Check only)
```bash
# Check lib directory (default) - like dart format --set-exit-if-changed
dart run import_order_lint:import_order --set-exit-if-changed

# Check with verbose output
dart run import_order_lint:import_order --set-exit-if-changed -v

# Check specific paths
dart run import_order_lint:import_order --set-exit-if-changed lib test
```

### 🎯 **Smart Defaults**
- **Auto-detects project name** from `pubspec.yaml`
- **Defaults to `lib` directory** if no paths specified
- **Recursive by default** for directories
- **Perfect CI/CD integration** with proper exit codes

### 📋 **Available Options**
- `-h, --help` - Show help information
- `-v, --verbose` - Show detailed output
- `--set-exit-if-changed` - Return exit code 1 if imports would be changed (like `dart format`)
- `-c, --check` - Same as `--set-exit-if-changed`
- `--dry-run` - Same as `--check`
- `--project-name=NAME` - Explicitly set project name (auto-detected by default)

### 🛠️ **Convenience Scripts**

The package includes convenience scripts in the `scripts/` directory:

```bash
# Development (fix imports)
scripts/fix_imports.sh        # Linux/macOS
scripts/fix_imports.bat       # Windows

# CI/CD (check imports)
scripts/check_imports.sh      # Linux/macOS
scripts/check_imports.bat     # Windows
```

## 🚀 **CI/CD Integration**

Perfect for automated pipelines - just like `dart format --set-exit-if-changed`:

```yaml
# GitHub Actions
- name: Check code formatting
  run: dart format --set-exit-if-changed .

- name: Check import ordering
  run: dart run import_order_lint:import_order --set-exit-if-changed

# Or using convenience scripts
- name: Check import ordering
  run: scripts/check_imports.sh
```

**Exit Codes:**
- ✅ **0**: All imports correctly ordered (CI passes)
- ❌ **1**: Import issues found (CI fails)

## Example

Here's an example of properly ordered imports:

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart';
import 'package:path/path.dart';

import 'package:myapp/models/user.dart';
import 'package:myapp/utils.dart';
```

## Testing

Run all regression tests:

```bash
dart test test/fix_imports_test.dart
```

Run specific test:

```bash
dart test test/fix_imports_test.dart -n "Regression test for code duplication"
```

Testing covers:

+ repeated lines of code being included #9
+ multi-line imports - complex imports with show/hide clauses
+ all import categories - Dart, Flutter, External, Project, Relative
+ edge cases - already ordered imports, single categories, as clauses
+ whitespace handling - proper spacing between import groups and following code

## License

This project is licensed under the MIT License - see the LICENSE file
for details.
