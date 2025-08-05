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

// Class to represent an import block (import statement + associated comments)
class ImportBlock {
  final int startIndex;
  final int endIndex;
  final List<String> lines;
  final String importStatement;
  
  ImportBlock({
    required this.startIndex,
    required this.endIndex,
    required this.lines,
    required this.importStatement,
  });
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
    ..addFlag('check',
        abbr: 'c',
        negatable: false,
        help: 'Check import ordering without fixing (useful for CI/CD)')
    ..addFlag('set-exit-if-changed',
        negatable: false,
        help:
            'Return exit code 1 if imports would be changed (like dart format)')
    ..addFlag('dry-run',
        negatable: false,
        help: 'Same as --check, show what would be fixed without fixing')
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
    final bool checkMode = argResults['check'] as bool ||
        argResults['dry-run'] as bool ||
        argResults['set-exit-if-changed'] as bool;
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
              verbose: verbose,
              explicitProjectName: projectName,
              checkMode: checkMode);
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
            explicitProjectName: projectName,
            checkMode: checkMode);
        processedFiles.addAll(dirResults.processed);
        errors.addAll(dirResults.errors);
      } else {
        print('Warning: Cannot access $filePath');
      }
    }

    if (checkMode) {
      // In check mode, "errors" means files that need fixing.

      if (errors.isNotEmpty) {
        print('\n📝 Summary: Found import ordering issues in ${errors.length} file(s).');
        print('💡 To fix these issues, run the same command without --set-exit-if-changed');
        exit(1);
      } else {
        print(
            '\n✅ Import ordering is correct in all ${processedFiles.length} file(s).');
        exit(0);
      }
    } else {
      // Fix mode (original behavior).

      if (processedFiles.isNotEmpty) {
        print(
            '\nSuccessfully fixed import ordering in ${processedFiles.length} file(s).');
      }

      if (errors.isNotEmpty) {
        print('\nFailed to fix import ordering in ${errors.length} file(s).');
        exit(1);
      }
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
  
  # Check import ordering without fixing (CI/CD mode)
  dart fix_imports.dart --check -r lib
  
  # Return exit code 1 if imports would be changed (like dart format)
  dart fix_imports.dart --set-exit-if-changed -r lib
  
  # Dry run (same as --check)
  dart fix_imports.dart --dry-run -r lib
''');
}

({List<String> processed, List<String> errors}) _processDirectory(
  String dirPath, {
  required bool recursive,
  required bool verbose,
  String? explicitProjectName,
  required bool checkMode,
}) {
  final processed = <String>[];
  final errors = <String>[];

  try {
    final dir = Directory(dirPath);
    final entities = dir.listSync(recursive: recursive);

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final result = _processFile(entity.path,
            verbose: verbose,
            explicitProjectName: explicitProjectName,
            checkMode: checkMode);
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

bool _processFile(String filePath, {
    required bool verbose,
    required String? explicitProjectName,
    required bool checkMode}) {
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

    // Extract import blocks (import statements + their associated comments)
    final importBlocks = <ImportBlock>[];
    final importBlockIndices = <int>[];
    
    int i = 0;
    while (i < lines.length) {
      final line = lines[i].trim();
      
      if (line.startsWith('import ')) {
        // Found an import statement, extract the block
        final block = _extractImportBlock(lines, i);
        importBlocks.add(block);
        importBlockIndices.add(block.startIndex);
        i = block.endIndex + 1; // Move to next line after the block
      } else {
        i++;
      }
    }

    if (importBlocks.isEmpty) {
      if (verbose) {
        print('No imports found in $filePath');
      }
      return true;
    }

    // Get project name from pubspec.yaml.
    final projectName = explicitProjectName ?? _getProjectName(filePath);

    // Sort import blocks by their import statements
    final sortedImportBlocks = _sortImportBlocks(importBlocks, projectName);

    // Check if imports are already sorted correctly
    bool alreadySorted = true;
    for (int j = 0; j < importBlocks.length; j++) {
      if (importBlocks[j].importStatement.trim() != sortedImportBlocks[j].importStatement.trim()) {
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

    // Replace import blocks in the file
    if (importBlockIndices.isNotEmpty) {
      // Find the bounds of the import section
      final firstImportIndex = importBlockIndices.reduce((a, b) => a < b ? a : b);
      final lastImportIndex = importBlockIndices.reduce((a, b) => a > b ? a : b);
      
      // Find the actual end of the last import block
      final lastBlock = importBlocks[importBlockIndices.indexOf(lastImportIndex)];
      final lastImportEndIndex = lastBlock.endIndex;

      // Look for the first non-empty line after imports to preserve spacing
      int nextContentIndex = lastImportEndIndex + 1;
      while (nextContentIndex < lines.length && lines[nextContentIndex].trim().isEmpty) {
        nextContentIndex++;
      }

      // Remove the import section (including any blank lines immediately after)
      int endRemovalIndex = lastImportEndIndex + 1;
      while (endRemovalIndex < nextContentIndex && endRemovalIndex < lines.length) {
        endRemovalIndex++;
      }

      // Remove all import blocks and their trailing blank lines
      lines.removeRange(firstImportIndex, endRemovalIndex);

      // Insert sorted import blocks with proper spacing
      final blocksWithSpacing = <String>[];
      
      for (int j = 0; j < sortedImportBlocks.length; j++) {
        final block = sortedImportBlocks[j];
        blocksWithSpacing.addAll(block.lines);
        
        // Add blank line between blocks if not the last one
        if (j < sortedImportBlocks.length - 1) {
          blocksWithSpacing.add('');
        }
      }

      // Add one blank line after imports if there's content following
      if (firstImportIndex < lines.length && lines[firstImportIndex].trim().isNotEmpty) {
        blocksWithSpacing.add('');
      }

      lines.insertAll(firstImportIndex, blocksWithSpacing);
    }

    // Compare with original content to check if changes are needed
    final newContent = lines.join('\n');
    final hasChanges = content != newContent;

    if (checkMode) {
      if (hasChanges) {
        // Provide detailed feedback about what's wrong
        _reportImportIssues(filePath, 
            importBlocks.map((b) => b.importStatement).toList(),
            sortedImportBlocks.map((b) => b.importStatement).toList(), 
            verbose);
        return false;
      } else {
        if (verbose) {
          print('✅ Import ordering is correct in $filePath');
        }
        return true;
      }
    }

    // Fix mode: Write back to file only if there are changes
    if (hasChanges) {
      file.writeAsStringSync(newContent);
      if (verbose) {
        print('Successfully fixed import ordering in $filePath');
      }
      return true;
    } else {
      if (verbose) {
        print('No import ordering changes needed in $filePath');
      }
      return true;
    }
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

void _reportImportIssues(String filePath, List<String> originalImports, 
    List<String> sortedImports, bool verbose) {
  print('❌ Import ordering issues found in $filePath:');
  
  // Compare line by line to find specific issues
  final issues = <String>[];
  
  // Filter out blank lines for comparison
  final originalNonEmpty = originalImports.where((line) => line.trim().isNotEmpty).toList();
  final sortedNonEmpty = sortedImports.where((line) => line.trim().isNotEmpty).toList();
  
  // Check for order issues
  for (int i = 0; i < originalNonEmpty.length && i < sortedNonEmpty.length; i++) {
    final original = originalNonEmpty[i].trim();
    final sorted = sortedNonEmpty[i].trim();
    
    if (original != sorted) {
      final originalPath = _extractImportPath(original);
      final sortedPath = _extractImportPath(sorted);
      
      if (originalPath != sortedPath) {
        final originalCategory = _getCategoryName(_getImportCategory(original, ''));
        final sortedCategory = _getCategoryName(_getImportCategory(sorted, ''));
        
        if (originalCategory != sortedCategory) {
          issues.add('   • $originalCategory import \'$originalPath\' should come after $sortedCategory imports');
        } else {
          issues.add('   • Import \'$originalPath\' should come before \'$sortedPath\' (alphabetical order)');
        }
        break; // Show first major issue to avoid overwhelming output
      }
    }
  }
  
  // Check for missing blank lines between groups  
  if (_hasMissingGroupSeparation(originalImports)) {
    issues.add('   • Missing blank lines between different import groups');
  }
  
  // Check for extra imports or missing imports
  if (originalNonEmpty.length != sortedNonEmpty.length) {
    issues.add('   • Import count mismatch - some imports may be duplicated or missing');
  }
  
  if (issues.isEmpty) {
    issues.add('   • Import order needs to be reorganized');
  }
  
  for (final issue in issues) {
    print(issue);
  }
  
  if (verbose) {
    print('   Expected order:');
    print('     1. Dart SDK imports (dart:*)');
    print('     2. Flutter imports (package:flutter/*)');
    print('     3. External packages (package:*)');
    print('     4. Project imports (package:project_name/*)');
    print('     5. Relative imports (../, ./)');
    print('     (with blank lines between groups)');
  }
}

String _extractImportPath(String importLine) {
  final singleQuoteMatch = importLine.indexOf("'");
  final doubleQuoteMatch = importLine.indexOf('"');
  
  if (singleQuoteMatch >= 0) {
    final startIndex = singleQuoteMatch + 1;
    final endIndex = importLine.indexOf("'", startIndex);
    if (endIndex > startIndex) {
      return importLine.substring(startIndex, endIndex);
    }
  } else if (doubleQuoteMatch >= 0) {
    final startIndex = doubleQuoteMatch + 1; 
    final endIndex = importLine.indexOf('"', startIndex);
    if (endIndex > startIndex) {
      return importLine.substring(startIndex, endIndex);
    }
  }
  return importLine;
}

String _getCategoryName(ImportCategory category) {
  switch (category) {
    case ImportCategory.dart:
      return 'Dart SDK';
    case ImportCategory.flutter:
      return 'Flutter';
    case ImportCategory.external:
      return 'External package';
    case ImportCategory.project:
      return 'Project';
    case ImportCategory.relative:
      return 'Relative';
  }
}

bool _hasMissingGroupSeparation(List<String> imports) {
  // Check if there are imports from different categories without blank line separation
  ImportCategory? lastCategory;
  
  for (final importLine in imports) {
    if (importLine.trim().isEmpty) {
      lastCategory = null; // Reset on blank line
      continue;
    }
    
    if (importLine.trim().startsWith('import ')) {
      final category = _getImportCategory(importLine, '');
      if (lastCategory != null && lastCategory != category) {
        return true; // Found category change without blank line
      }
      lastCategory = category;
    }
  }
  
  return false;
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

// Extract an import block starting from the given index
ImportBlock _extractImportBlock(List<String> lines, int startIndex) {
  final blockLines = <String>[];
  int currentIndex = startIndex;
  String importStatement = '';
  bool importComplete = false;
  
  // First, collect all lines that are part of the import statement
  while (currentIndex < lines.length && !importComplete) {
    final line = lines[currentIndex];
    blockLines.add(line);
    
    if (line.trim().startsWith('import ')) {
      importStatement = line;
      // Check if this is a single-line import
      if (line.trim().endsWith(';')) {
        importComplete = true;
      }
    } else if (importStatement.isNotEmpty) {
      // Continue building multi-line import
      importStatement += '\n' + line;
      if (line.trim().contains(';')) {
        importComplete = true;
      }
    }
    
    currentIndex++;
  }
  
  // Now look for associated comments that should move with this import
  // Comments that immediately precede the import (no empty line) should move with it
  int commentStartIndex = startIndex - 1;
  while (commentStartIndex >= 0) {
    final line = lines[commentStartIndex];
    final trimmedLine = line.trim();
    
    if (trimmedLine.isEmpty) {
      // Found empty line, stop looking for comments
      break;
    } else if (trimmedLine.startsWith('//') || trimmedLine.startsWith('/*')) {
      // Found a comment, add it to the beginning of the block
      blockLines.insert(0, line);
      commentStartIndex--;
    } else {
      // Found non-comment, non-empty line, stop
      break;
    }
  }
  
  return ImportBlock(
    startIndex: commentStartIndex + 1,
    endIndex: currentIndex - 1,
    lines: blockLines,
    importStatement: importStatement,
  );
}

// Sort import blocks by their import statements
List<ImportBlock> _sortImportBlocks(List<ImportBlock> blocks, String projectName) {
  // Extract just the import statements for sorting
  final importStatements = blocks.map((b) => b.importStatement).toList();
  final sortedImportStatements = _sortImports(importStatements, projectName);
  
  // Create a map from import statement to block for easy lookup
  final blockMap = <String, ImportBlock>{};
  for (final block in blocks) {
    blockMap[block.importStatement] = block;
  }
  
  // Return blocks in the sorted order
  return sortedImportStatements.map((import) => blockMap[import]).whereType<ImportBlock>().toList();
}
