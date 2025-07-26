# Import Order Lint Changelog

Recorded here are the high level changes for the dart
import_order_lint package.

Guide: Each version update is recorded here with a short user-oriented
description of the update. Updates in the 0.1.n series are heading
toward a 0.2 release.  The `[version timestamp user]` string is
utilised by the flutter version_widget package.

The package is available from
[pub.dev](https://pub.dev/packages/import_order_lint).

## 0.2.0 Standalone Tool Architecture (BREAKING CHANGES)

+ **BREAKING**: Migrate from custom_lint plugin to standalone ergonomic tool [0.2.0 20250130 atangster]
  - Remove all custom_lint/analyzer dependencies (eliminates version conflicts)
  - Add ergonomic `import_order.dart` with dart format-like UX
  - Auto-detect project name from pubspec.yaml (no manual --project-name needed)
  - Add --set-exit-if-changed flag for CI/CD (matching dart format behavior)  
  - Restructure package: docs/ and scripts/ directories following Dart conventions
  - Update example project to demonstrate standalone tool usage
  - Simplify commands from 95+ chars to ~60 chars (31% reduction)
  - Remove 33KB+ of plugin code, 3.2MB of log files
## 0.1 Plugin-Based Releases

+ Update analyzer/custom_lint_builder dependencies to any [0.1.2 20250725 atangster]
+ Bug fix for errant duplicate code [0.1.1 20250703 atangster]
+ Fix multiple line import handling. [0.1.0 20250627 atangster]
+ Automatic import fixer (`fix_imports`) [0.1.0 20250503 atangster]
+ CLI import fixer/recursive directory scanning [0.1.0 20250503 atangster]

## 0.0 Initial release

+ Remove unnecessary dependencies [0.0.3 20250404 gjw]
