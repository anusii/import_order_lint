<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Import Order Lint

A custom lint plugin for enforcing consistent import ordering in Dart files.

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

1. Add the package to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: ^0.6.10
  import_order_lint: ^0.0.1
```

2. Create or update your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
  custom_lint:
    rules:
      - import_order_lint
```

## Usage

The lint rule will automatically analyze your Dart files and report any import ordering issues. You can run the linter using:

```bash
dart run custom_lint
```

By default, the plugin will use your package name from `pubspec.yaml` to identify project-specific imports. If you need to override this, you can set the `DART_PROJECT_NAME` environment variable:

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

import '../models/user.dart';
import './utils.dart';
```

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.
