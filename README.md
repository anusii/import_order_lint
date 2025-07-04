[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![GitHub License](https://img.shields.io/github/license/anusii/import_order_lint)](https://raw.githubusercontent.com/anusii/import_order_lint/main/LICENSE)
[![GitHub Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/anusii/import_order_lint/master/pubspec.yaml&query=$.version&label=version&logo=github)](https://github.com/anusii/import_order_lint/blob/dev/CHANGELOG.md)
[![Pub Version](https://img.shields.io/pub/v/import_order_lint?label=pub.dev&labelColor=333940&logo=flutter)](https://pub.dev/packages/import_order_lint)
[![GitHub Last Updated](https://img.shields.io/github/last-commit/anusii/import_order_lint?label=last%20updated)](https://github.com/anusii/import_order_lint/commits/main/)
[![GitHub Commit Activity (main)](https://img.shields.io/github/commit-activity/w/anusii/import_order_lint/main)](https://github.com/anusii/import_order_lint/commits/main/)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/import_order_lint)](https://github.com/anusii/import_order_lint/issues)

# Import Order Lint

A custom lint plugin for enforcing consistent import ordering in Dart
files as documented in the [Flutter Style Guide](https://survivor.togaware.com/gnulinux/flutter-style-imports.html).

The package is published on the Flutter repository at
[pub.dev](https://pub.dev/packages/import_order_lint).

## Features

- Enforces consistent import ordering across your Dart/Flutter project
- Groups imports into categories:
  1. Dart SDK imports (e.g., 'dart:core', 'dart:async')
  2. Flutter imports (packages starting with 'package:flutter/')
  3. External package imports (other 'package:' imports)
  4. Project imports (relative path imports)
- Requires blank lines between different import groups
- Sorts imports alphabetically within each group

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: ^0.7.5
  import_order_lint: ^0.1.1
```

### Configuration

Create or update your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - import_order_lint
  options:
    import_order_lint:
      project_name: myapp
```

## Usage

The lint rule will automatically analyze your Dart files and report
any import ordering issues. You can run the linter using:

```bash
dart run custom_lint
```

### Project Name Identification

For correct import categorization, the tool needs to know your project
name. By default, it tries to determine this from your `pubspec.yaml`
file, but this may not always work correctly, especially in complex
repository structures.

You have two options to ensure correct project name identification:

1. For linting with `custom_lint`, set the `DART_PROJECT_NAME` environment variable:

```bash
# On Unix-like systems (Linux, macOS)
DART_PROJECT_NAME=my_project dart run custom_lint

# On Windows PowerShell
$env:DART_PROJECT_NAME="my_project"; dart run custom_lint
```

2. For the import fixer tool, use the `--project-name` parameter (recommended):

```bash
dart run import_order_lint:fix_imports --project-name=my_project -r lib
```

This ensures that imports starting with `package:my_project/` are
correctly identified as project imports and separated from external
package imports.

## Automatic Import Fixer

This package also includes a command-line tool to automatically fix import ordering in your files:

```bash
# If installed as a dependency
dart run import_order_lint:fix_imports [options] <file_or_directory_paths>

# If activated globally
dart pub global activate import_order_lint
fix_imports [options] <file_or_directory_paths>
```

### Options

- `-r, --recursive`: Recursively search for Dart files in directories
- `-v, --verbose`: Show verbose output
- `-h, --help`: Print usage information
- `--project-name=<name>`: Explicitly set the project name for correct import categorization

### Examples

```bash
# Fix a single file
dart run import_order_lint:fix_imports lib/main.dart

# Fix all Dart files in a directory recursively
dart run import_order_lint:fix_imports -r lib

# Fix multiple files with verbose output
dart run import_order_lint:fix_imports -v lib/main.dart lib/widgets/app.dart

# Fix imports with explicit project name (recommended)
dart run import_order_lint:fix_imports --project-name=myapp -r lib
```

### Integration with CI/CD

You can integrate the import fixer into your CI/CD pipeline to ensure consistent import ordering:

```yaml
# Example GitHub Actions workflow step
- name: Fix import ordering
  run: dart run import_order_lint:fix_imports --project-name=myapp -r lib

# Check if any files were changed (will fail if imports were fixed)
- name: Check for changes
  run: git diff --exit-code
```

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
