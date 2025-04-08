[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![Pub Package](https://img.shields.io/pub/v/import_order_lint)](https://pub.dev/packages/import_order_lint)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/import_order_lint)](https://github.com/anusii/import_order_lint/issues)
[![GitHub License](https://img.shields.io/github/license/anusii/import_order_lint)](https://raw.githubusercontent.com/anusii/import_order_lint/main/LICENSE)

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
  custom_lint: ^0.6.10
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
      project_name: my_project
```

## Usage

The lint rule will automatically analyze your Dart files and report
any import ordering issues. You can run the linter using:

```bash
dart run custom_lint
```

### Project Name Identification

For correct import categorization, the tool needs to know your project name. By default, it tries to determine this from your `pubspec.yaml` file, but this may not always work correctly, especially in complex repository structures.

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

This ensures that imports starting with `package:my_project/` are correctly identified as project imports and separated from external package imports.

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

## License

This project is licensed under the MIT License - see the LICENSE file
for details.
