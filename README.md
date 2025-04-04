[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![Pub Package](https://img.shields.io/pub/v/import_order_lint)](https://pub.dev/packages/import_order_lint)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/import_order_lint)](https://github.com/anusii/import_order_lint/issues)
[![GitHub License](https://img.shields.io/github/license/anusii/import_order_lint)](https://raw.githubusercontent.com/anusii/import_order_lint/main/LICENSE)

# Import Order Lint

A custom lint plugin for enforcing consistent import ordering in Dart files.

Published through the Flutter repository as
https://pub.dev/packages/import_order_lint.

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
  import_order_lint: ^0.0.3
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
```

## Usage

The lint rule will automatically analyze your Dart files and report
any import ordering issues. You can run the linter using:

```bash
dart run custom_lint
```

By default, the plugin will use your package name from `pubspec.yaml`
to identify project-specific imports. If you need to override this,
you can set the `DART_PROJECT_NAME` environment variable:

```bash
# On Unix-like systems (Linux, macOS)
DART_PROJECT_NAME=my_project dart run custom_lint

# On Windows PowerShell
$env:DART_PROJECT_NAME="my_project"; dart run custom_lint
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
