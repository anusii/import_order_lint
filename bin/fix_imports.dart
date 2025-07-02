#!/usr/bin/env dart
// A script to automatically fix import ordering in Dart files.
///
// Time-stamp: <Thursday 2025-01-30 08:36:00 +1100 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Ashley Tang

library;

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

// Define categories for import sorting.

enum ImportCategory {
  dart,
  flutter,
  external,
  project,
  relative,
}

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Print usage information')
    ..addFlag('recursive',
        abbr: 'r',
        negatable: false,
        help: 'Recursively search for Dart files in directories')
    ..addFlag('verbose',
        abbr: 'v', negatable: false, help: 'Show verbose output')
    ..addOption('project-name',
        help: 'Explicitly set the project name for import categorization');

  try {
    final argResults = parser.parse(args);

    if (argResults['help'] as bool) {
      _printUsage(parser);
      exit(0);
    }

    final bool verbose = argResults['verbose'] as bool;
    final bool recursive = argResults['recursive'] as bool;
    final String? explicitProjectName = argResults['project-name'] as String?;
    final List<String> filePaths = argResults.rest;

    if (filePaths.isEmpty) {
      print('Error: No files or directories specified.');
      _printUsage(parser);
      exit(1);
    }

    final processedFiles = <String>[];
    final errors = <String>[];

    // If an explicit project name is provided, use it.

    final projectName =
        explicitProjectName != null && explicitProjectName.isNotEmpty
            ? explicitProjectName
            : null;

    for (final filePath in filePaths) {
      final fileOrDir = FileSystemEntity.typeSync(filePath);

      if (fileOrDir == FileSystemEntityType.file) {
        if (filePath.endsWith('.dart')) {
          final result = _processFile(filePath,
              verbose: verbose, explicitProjectName: projectName);
          if (result) {
            processedFiles.add(filePath);
          } else {
            errors.add(filePath);
          }
        } else if (verbose) {
          print('Skipping non-Dart file: $filePath');
        }
      } else if (fileOrDir == FileSystemEntityType.directory) {
        final dirResults = _processDirectory(filePath,
            recursive: recursive,
            verbose: verbose,
            explicitProjectName: projectName);
        processedFiles.addAll(dirResults.processed);
        errors.addAll(dirResults.errors);
      } else {
        print('Warning: Cannot access $filePath');
      }
    }

    if (processedFiles.isNotEmpty) {
      print(
          '\nSuccessfully fixed import ordering in ${processedFiles.length} file(s).');
    }

    if (errors.isNotEmpty) {
      print('\nFailed to fix import ordering in ${errors.length} file(s).');
      exit(1);
    }
  } catch (e) {
    print('Error: $e');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('''
import_order_lint - A tool to fix import ordering in Dart files.

Usage: dart fix_imports.dart [options] <file_or_directory_paths>

Options:
${parser.usage}

Examples:
  # Fix a single file
  dart fix_imports.dart lib/main.dart
  
  # Fix all Dart files in a directory
  dart fix_imports.dart -r lib
  
  # Fix multiple files with verbose output
  dart fix_imports.dart -v lib/main.dart lib/widgets/app.dart
  
  # Fix imports with explicit project name
  dart fix_imports.dart --project-name=myapp lib/main.dart
''');
}

({List<String> processed, List<String> errors}) _processDirectory(
  String dirPath, {
  required bool recursive,
  required bool verbose,
  String? explicitProjectName,
}) {
  final processed = <String>[];
  final errors = <String>[];

  try {
    final dir = Directory(dirPath);
    final entities = dir.listSync(recursive: recursive);

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final result = _processFile(entity.path,
            verbose: verbose, explicitProjectName: explicitProjectName);
        if (result) {
          processed.add(entity.path);
        } else {
          errors.add(entity.path);
        }
      }
    }
  } catch (e) {
    print('Error processing directory $dirPath: $e');
  }

  return (processed: processed, errors: errors);
}

bool _processFile(String filePath,
    {required bool verbose, String? explicitProjectName}) {
  try {
    if (verbose) {
      print('Processing: $filePath');
    }

    final file = File(filePath);

    if (!file.existsSync()) {
      if (verbose) {
        print('File not found: $filePath');
      }
      return false;
    }

    final content = file.readAsStringSync();
    final lines = content.split('\n');

    // Find import lines, handling multi-line imports.
    // First, identify all import statements and their line ranges.

    final importLines = <String>[];
    final importLineIndices = <int>[];
    String? currentImport = null;
    int? currentImportStartIndex = null;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('import ')) {
        // Start of a new import.

        // If we were building a previous import, save it first.

        if (currentImport != null && currentImportStartIndex != null) {
          importLines.add(currentImport);
          importLineIndices.add(currentImportStartIndex);
        }

        currentImport = lines[i];
        currentImportStartIndex = i;

        // Check if this is a single-line import (ends with semicolon).

        if (line.endsWith(';')) {
          importLines.add(currentImport);
          importLineIndices.add(currentImportStartIndex);
          currentImport = null;
          currentImportStartIndex = null;
        }
      } else if (currentImport != null && currentImportStartIndex != null) {
        // Continue building the multi-line import.

        currentImport += '\n' + lines[i];

        // Check if this line ends the import (contains semicolon).

        if (line.contains(';')) {
          importLines.add(currentImport);
          importLineIndices.add(currentImportStartIndex);
          currentImport = null;
          currentImportStartIndex = null;
        }
      }
    }

    // Handle the last import if it wasn't closed.

    if (currentImport != null && currentImportStartIndex != null) {
      importLines.add(currentImport);
      importLineIndices.add(currentImportStartIndex);
    }

    if (importLines.isEmpty) {
      if (verbose) {
        print('No imports found in $filePath');
      }
      return true;
    }

    // Get project name from pubspec.yaml.

    final projectName = explicitProjectName ?? _getProjectName(filePath);

    // Sort imports.

    final sortedImports = _sortImports(importLines, projectName);

    // Check if imports are already sorted correctly.

    bool alreadySorted = true;
    for (int i = 0; i < importLines.length; i++) {
      if (importLines[i].trim() != sortedImports[i].trim()) {
        alreadySorted = false;
        break;
      }
    }

    if (alreadySorted) {
      if (verbose) {
        print('Imports already correctly ordered in $filePath');
      }
      return true;
    }

    // Replace imports in the file.
    // Remove all existing import lines, then insert sorted imports at the first import position.

    if (importLineIndices.isNotEmpty) {
      // Find the bounds of the import section.

      final firstImportIndex =
          importLineIndices.reduce((a, b) => a < b ? a : b);
      final lastImportIndex = importLineIndices.reduce((a, b) => a > b ? a : b);

      // Find the actual end of the last import (including multi-line).

      final lastImportText =
          importLines[importLineIndices.indexOf(lastImportIndex)];
      final lastImportEndIndex =
          lastImportIndex + lastImportText.split('\n').length - 1;

      // Look for the first non-empty line after imports to preserve spacing.

      int nextContentIndex = lastImportEndIndex + 1;
      while (nextContentIndex < lines.length &&
          lines[nextContentIndex].trim().isEmpty) {
        nextContentIndex++;
      }

      // Remove the import section (including any blank lines immediately after).

      int endRemovalIndex = lastImportEndIndex + 1;
      while (endRemovalIndex < nextContentIndex &&
          endRemovalIndex < lines.length) {
        endRemovalIndex++;
      }

      // Remove all import lines and their trailing blank lines.

      lines.removeRange(firstImportIndex, endRemovalIndex);

      // Insert sorted impo rts with proper spacing.

      final importsWithSpacing = <String>[...sortedImports];

      // Add one blank line after imports if there's content following.

      if (firstImportIndex < lines.length &&
          lines[firstImportIndex].trim().isNotEmpty) {
        importsWithSpacing.add('');
      }

      lines.insertAll(firstImportIndex, importsWithSpacing);
    }

    // Write back to file.

    file.writeAsStringSync(lines.join('\n'));

    if (verbose) {
      print('Successfully fixed import ordering in $filePath');
    }
    return true;
  } catch (e) {
    print('Error processing file $filePath: $e');
    return false;
  }
}

String _getProjectName(String filePath) {
  try {
    // Try to find pubspec.yaml in directory or parent directories.

    Directory current = Directory(path.dirname(filePath));

    while (current.path != current.parent.path) {
      final pubspecPath = path.join(current.path, 'pubspec.yaml');
      final pubspecFile = File(pubspecPath);

      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        final nameMatch = RegExp(r'name:\s*([^\s]+)').firstMatch(content);
        return nameMatch?.group(1) ?? '';
      }

      current = current.parent;
    }

    return '';
  } catch (e) {
    print('Error getting project name: $e');
    return '';
  }
}

List<String> _sortImports(List<String> imports, String projectName) {
  // Categorise imports.

  final dartImports = <String>[];
  final flutterImports = <String>[];
  final externalImports = <String>[];
  final projectImports = <String>[];
  final relativeImports = <String>[];

  for (final import in imports) {
    final category = _getImportCategory(import, projectName);
    switch (category) {
      case ImportCategory.dart:
        dartImports.add(import);
        break;
      case ImportCategory.flutter:
        flutterImports.add(import);
        break;
      case ImportCategory.external:
        externalImports.add(import);
        break;
      case ImportCategory.project:
        projectImports.add(import);
        break;
      case ImportCategory.relative:
        relativeImports.add(import);
        break;
    }
  }

  // Sort each category.

  dartImports.sort();
  flutterImports.sort();
  externalImports.sort();
  projectImports.sort();
  relativeImports.sort();

  // Combine with blank lines between categories.

  final result = <String>[];

  if (dartImports.isNotEmpty) {
    result.addAll(dartImports);
    if (flutterImports.isNotEmpty ||
        externalImports.isNotEmpty ||
        projectImports.isNotEmpty ||
        relativeImports.isNotEmpty) {
      result.add('');
    }
  }

  if (flutterImports.isNotEmpty) {
    result.addAll(flutterImports);
    if (externalImports.isNotEmpty ||
        projectImports.isNotEmpty ||
        relativeImports.isNotEmpty) {
      result.add('');
    }
  }

  if (externalImports.isNotEmpty) {
    result.addAll(externalImports);
    if (projectImports.isNotEmpty || relativeImports.isNotEmpty) {
      result.add('');
    }
  }

  if (projectImports.isNotEmpty) {
    result.addAll(projectImports);
    if (relativeImports.isNotEmpty) {
      result.add('');
    }
  }

  if (relativeImports.isNotEmpty) {
    result.addAll(relativeImports);
  }

  return result;
}

ImportCategory _getImportCategory(String importLine, String projectName) {
  // Extract package path.

  final singleQuoteMatch = importLine.indexOf("import '");
  final doubleQuoteMatch = importLine.indexOf('import "');

  String importPath = '';

  if (singleQuoteMatch >= 0) {
    final startIndex = importLine.indexOf("'") + 1;
    final endIndex = importLine.indexOf("'", startIndex);
    if (endIndex > startIndex) {
      importPath = importLine.substring(startIndex, endIndex);
    }
  } else if (doubleQuoteMatch >= 0) {
    final startIndex = importLine.indexOf('"') + 1;
    final endIndex = importLine.indexOf('"', startIndex);
    if (endIndex > startIndex) {
      importPath = importLine.substring(startIndex, endIndex);
    }
  } else {
    // Extract package path using split (fallback).

    final parts = importLine.trim().split(' ');
    if (parts.length >= 2) {
      String path =
          parts[1].replaceAll("'", "").replaceAll('"', '').replaceAll(';', '');
      importPath = path;
    }
  }

  if (importPath.startsWith('dart:')) {
    return ImportCategory.dart;
  } else if (importPath.startsWith('package:flutter/')) {
    return ImportCategory.flutter;
  } else if (projectName.isNotEmpty &&
      importPath.startsWith('package:$projectName/')) {
    return ImportCategory.project;
  } else if (importPath.startsWith('package:')) {
    return ImportCategory.external;
  } else {
    return ImportCategory.relative;
  }
}
