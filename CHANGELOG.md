# Import Order Lint Changelog

Recorded here are the high level changes for the dart
import_order_lint package.

Guide: Each version update is recorded here with a short user-oriented
description of the update. Updates in the 0.1.n series are heading
toward a 0.2 release.  The `[version timestamp user]` string is
utilised by the flutter version_widget package.

The package is available from
[pub.dev](https://pub.dev/packages/import_order_lint).

## 0.2.2 Import Spacing Fix

+ **FIX**: Correct spacing between import groups to follow Flutter style guide [0.2.2 20250130 atangster]
  - Fix bug where blank lines were added between every import instead of only between categories
  - Remove early exit logic that bypassed spacing checks when imports were correctly ordered
  - Ensure blank lines only appear between different import categories (dart, flutter, external, project, relative)
  - No blank lines within the same import category (e.g., between external packages)
  - Fixes GitHub issue #17: "Import order fix is adding extra spaces"

## 0.2.1 Comment Preservation Fix

+ **FIX**: Preserve comments associated with imports during reordering [0.2.1 20250130 atangster]
  - Comments that immediately precede imports (no empty line) now move with their imports
  - Multi-line comments are preserved and move with their associated imports
  - Comments with empty lines after them stay in their original position
  - Fixes GitHub issue #15: "Comments in the import section are lost with a import_order fix"

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
