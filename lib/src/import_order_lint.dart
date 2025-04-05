/// Import order lint widget.
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

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as analyzer;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart' as custom_lint;
import 'package:yaml/yaml.dart';

import 'import_visitor.dart';

/// A custom lint rule that enforces consistent import ordering in Dart files.
///
/// This rule ensures imports are grouped and ordered according to the following conventions:
/// 1. Dart SDK imports (e.g., 'dart:core', 'dart:async')
/// 2. Flutter imports (packages starting with 'package:flutter/')
/// 3. External package imports (other 'package:' imports)
/// 4. Project imports (relative path imports)
///
/// Within each group, imports are sorted alphabetically for consistency.
///
/// Example of properly ordered imports:
/// ```dart
/// import 'dart:async';
/// import 'dart:io';
///
/// import 'package:flutter/material.dart';
/// import 'package:flutter/services.dart';
///
/// import 'package:http/http.dart';
/// import 'package:path/path.dart';
///
/// import '../models/user.dart';
/// import './utils.dart';
/// ```
///
/// To use this lint rule, add it to your analysis_options.yaml file:
/// ```yaml
/// analyzer:
///   plugins:
///     - custom_lint
///   custom_lint:
///     rules:
///       - import_order_lint
/// ```
///
/// By default, the plugin will use your package name from pubspec.yaml to identify project-specific imports.
/// If you need to override this, you can set the DART_PROJECT_NAME environment variable:
/// ```bash
/// DART_PROJECT_NAME=my_project dart run custom_lint
/// ```

/// Finds the project root directory by looking for pubspec.yaml in parent directories.

String _findProjectRoot(String startPath) {
  var current = Directory(startPath);
  while (current.path != current.parent.path) {
    if (File('${current.path}/pubspec.yaml').existsSync()) {
      return current.path;
    }
    current = current.parent;
  }
  return startPath;
}

/// Gets the package name from the project's pubspec.yaml file.

String _getPackageNameFromPubspec(String projectPath) {
  final pubspecFile = File('$projectPath/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    return '';
  }

  try {
    final contents = pubspecFile.readAsStringSync();
    final yaml = loadYaml(contents);
    return yaml['name'] as String? ?? '';
  } catch (e) {
    return '';
  }
}

class ImportOrderLint extends custom_lint.DartLintRule {
  /// Creates a new instance of [ImportOrderLint].
  ///
  /// This constructor initialises the rule with the predefined lint code.

  ImportOrderLint() : super(code: _code);

  /// The lint code definition for import ordering.
  ///
  /// This code is used to identify the lint rule in analysis results and
  /// must match the rule name in analysis_options.yaml.

  static final custom_lint.LintCode _code = custom_lint.LintCode(
    name: 'ordered_imports',
    problemMessage:
        'Imports should be properly ordered, sorted within groups, and groups separated by blank lines.',
    errorSeverity: analyzer.ErrorSeverity.INFO,
  );

  /// Additional lint code for import group separation.
  
  static final custom_lint.LintCode _separationCode = custom_lint.LintCode(
    name: 'import_group_separation',
    problemMessage:
        'Different import categories should be separated by blank lines.',
    errorSeverity: analyzer.ErrorSeverity.INFO,
  );

  /// Provides access to the lint code for external use.

  static custom_lint.LintCode get lintCode => _code;
  static custom_lint.LintCode get separationLintCode => _separationCode;

  @override
  void run(
    custom_lint.CustomLintResolver resolver,
    ErrorReporter reporter,
    custom_lint.CustomLintContext context,
  ) {
    // Get the project name from environment variable or pubspec.yaml.

    final envProjectName = Platform.environment['DART_PROJECT_NAME'];
    final projectName = envProjectName ?? 
        _getPackageNameFromPubspec(_findProjectRoot(resolver.path));

    // Process the resolved unit result to analyze import statements.

    resolver.getResolvedUnitResult().then((ResolvedUnitResult result) {
      // Generate source code representation for analysis.
      result.unit.toSource();

      // Create and run the import visitor to check import ordering.

      final visitor = ImportVisitor(reporter, projectName: projectName);
      visitor.visitCompilationUnit(result.unit);
    }).catchError((error) {
      // Errors during analysis should be handled gracefully
      // In a production environment, consider logging these errors
      // print('[ERROR] Exception in getResolvedUnitResult(): $error');
      
    });
  }

  /// [LintRule]s can optionally specify a list of quick-fixes.
  ///
  /// Fixes will show-up in the IDE when the cursor is above the warning. And it
  /// should contain a message explaining how the warning will be fixed.
  @override
  List<custom_lint.Fix> getFixes() => [
        _ReorderImportsFix(),
        _FixImportSeparationFix(),
      ];
}

/// Helper method to sort import information objects.
List<_ImportInfo> _sortImportsInfo(List<_ImportInfo> imports, String projectName) {
  // Categorize imports.
  List<_ImportInfo> dartImports = [];
  List<_ImportInfo> flutterImports = [];
  List<_ImportInfo> externalImports = [];
  List<_ImportInfo> projectImports = [];
  List<_ImportInfo> relativeImports = [];

  for (var import in imports) {
    final uriStr = import.uriString;
    if (uriStr.startsWith("dart:")) {
      dartImports.add(import);
    } else if (uriStr.startsWith("package:flutter/")) {
      flutterImports.add(import);
    } else if (uriStr.startsWith("package:$projectName/")) {
      projectImports.add(import);
    } else if (uriStr.startsWith("package:")) {
      externalImports.add(import);
    } else {
      // This captures relative imports that don't start with "package:"
      relativeImports.add(import);
    }
  }

  // Sort each category alphabetically by URI.
  dartImports.sort((a, b) => a.uriString.compareTo(b.uriString));
  flutterImports.sort((a, b) => a.uriString.compareTo(b.uriString));
  externalImports.sort((a, b) => a.uriString.compareTo(b.uriString));
  projectImports.sort((a, b) => a.uriString.compareTo(b.uriString));
  relativeImports.sort((a, b) => a.uriString.compareTo(b.uriString));

  // Combine sorted categories in the correct order.
  return [
    ...dartImports,
    ...flutterImports,
    ...externalImports,
    ...projectImports,
    ...relativeImports,
  ];
}

/// Helper method to get import category from URI string.
String _getImportCategory(String importUri, String projectName) {
  if (importUri.startsWith('dart:')) {
    return 'dart';
  } else if (importUri.startsWith('package:flutter/')) {
    return 'flutter';
  } else if (importUri.startsWith('package:$projectName/')) {
    return 'project';
  } else if (importUri.startsWith('package:')) {
    return 'external';
  }
  return 'relative';
}

/// Helper class to hold import information.
class _ImportInfo {
  final String uriString;
  final ImportDirective directive;
  final String? prefix;
  final bool hasShow;
  final bool hasHide;
  final String comment;

  _ImportInfo({
    required this.uriString,
    required this.directive,
    this.prefix,
    this.hasShow = false,
    this.hasHide = false,
    this.comment = '',
  });
}

/// A quick fix for automatically reordering imports to follow the convention.
///
/// This fix reorganizes all imports in the file according to the proper categories
/// and adds blank line separators between different import categories.
class _ReorderImportsFix extends custom_lint.DartFix {
  @override
  void run(
    custom_lint.CustomLintResolver resolver,
    custom_lint.ChangeReporter reporter,
    custom_lint.CustomLintContext context,
    analyzer.AnalysisError analysisError,
    List<analyzer.AnalysisError> others,
  ) {
    final envProjectName = Platform.environment['DART_PROJECT_NAME'];
    final projectName = envProjectName ?? 
        _getPackageNameFromPubspec(_findProjectRoot(resolver.path));

    resolver.getResolvedUnitResult().then((ResolvedUnitResult result) {
      final unit = result.unit;
      final imports = unit.directives.whereType<ImportDirective>().toList();
      
      if (imports.isEmpty) return;
      
      // Create a change builder for the fix
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Reorder imports',
        priority: 10,
      );
      
      changeBuilder.addDartFileEdit((builder) {
        // Get import details
        final allImports = imports.map((imp) {
          final uriStr = imp.uri.stringValue ?? '';
          final prefix = imp.prefix?.name;
          final combinators = imp.combinators;
          final comment = imp.documentationComment?.toString() ?? '';
          final isShow = combinators.any((c) => c is ShowCombinator);
          final isHide = combinators.any((c) => c is HideCombinator);
          
          return _ImportInfo(
            uriString: uriStr,
            directive: imp,
            prefix: prefix,
            hasShow: isShow,
            hasHide: isHide,
            comment: comment,
          );
        }).toList();
        
        // Sort imports
        final sortedInfos = _sortImportsInfo(allImports, projectName);
        
        // If the first import is not at the start of the file,
        // we need to be careful about leading comments
        final firstImport = imports.first;
        final lastImport = imports.last;
        
        // Replace the entire import section with properly formatted imports
        builder.addReplacement(
          SourceRange(
            firstImport.offset,
            lastImport.end - firstImport.offset,
          ),
          (builder) {
            String? lastCategory;
            
            for (int i = 0; i < sortedInfos.length; i++) {
              final importInfo = sortedInfos[i];
              final category = _getImportCategory(importInfo.uriString, projectName);
              
              // Add blank line between different categories
              if (lastCategory != null && lastCategory != category) {
                builder.writeln();
              }
              
              // Write the import statement
              builder.write('import \'${importInfo.uriString}\'');
              
              // Add prefix if present
              if (importInfo.prefix != null) {
                builder.write(' as ${importInfo.prefix}');
              }
              
              // Add combinators (show/hide) if present
              if (importInfo.hasShow || importInfo.hasHide) {
                final originalDirective = importInfo.directive.toSource();
                final uriEnd = originalDirective.indexOf("'", originalDirective.indexOf("'") + 1) + 1;
                final combinator = originalDirective.substring(uriEnd);
                builder.write(combinator);
              } else {
                builder.write(';');
              }
              
              builder.writeln();
              lastCategory = category;
            }
          },
        );
      });
    });
  }
}

/// A quick fix for adding proper spacing between import groups.
///
/// This fix reorganizes all imports in the file according to the proper categories
/// and adds blank line separators between different import categories.
class _FixImportSeparationFix extends custom_lint.DartFix {
  @override
  void run(
    custom_lint.CustomLintResolver resolver,
    custom_lint.ChangeReporter reporter,
    custom_lint.CustomLintContext context,
    analyzer.AnalysisError analysisError,
    List<analyzer.AnalysisError> others,
  ) {
    // Reuse the same implementation as _ReorderImportsFix since both fixes
    // effectively apply the same solution - reorganizing imports with proper spacing
    final envProjectName = Platform.environment['DART_PROJECT_NAME'];
    final projectName = envProjectName ?? 
        _getPackageNameFromPubspec(_findProjectRoot(resolver.path));

    resolver.getResolvedUnitResult().then((ResolvedUnitResult result) {
      final unit = result.unit;
      final imports = unit.directives.whereType<ImportDirective>().toList();
      
      if (imports.isEmpty) return;
      
      // Create a change builder for the fix
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add proper spacing between import groups',
        priority: 10,
      );
      
      changeBuilder.addDartFileEdit((builder) {
        // Get import details
        final allImports = imports.map((imp) {
          final uriStr = imp.uri.stringValue ?? '';
          final prefix = imp.prefix?.name;
          final combinators = imp.combinators;
          final comment = imp.documentationComment?.toString() ?? '';
          final isShow = combinators.any((c) => c is ShowCombinator);
          final isHide = combinators.any((c) => c is HideCombinator);
          
          return _ImportInfo(
            uriString: uriStr,
            directive: imp,
            prefix: prefix,
            hasShow: isShow,
            hasHide: isHide,
            comment: comment,
          );
        }).toList();
        
        // Sort imports
        final sortedInfos = _sortImportsInfo(allImports, projectName);
        
        // If the first import is not at the start of the file,
        // we need to be careful about leading comments
        final firstImport = imports.first;
        final lastImport = imports.last;
        
        // Replace the entire import section with properly formatted imports
        builder.addReplacement(
          SourceRange(
            firstImport.offset,
            lastImport.end - firstImport.offset,
          ),
          (builder) {
            String? lastCategory;
            
            for (int i = 0; i < sortedInfos.length; i++) {
              final importInfo = sortedInfos[i];
              final category = _getImportCategory(importInfo.uriString, projectName);
              
              // Add blank line between different categories
              if (lastCategory != null && lastCategory != category) {
                builder.writeln();
              }
              
              // Write the import statement
              builder.write('import \'${importInfo.uriString}\'');
              
              // Add prefix if present
              if (importInfo.prefix != null) {
                builder.write(' as ${importInfo.prefix}');
              }
              
              // Add combinators (show/hide) if present
              if (importInfo.hasShow || importInfo.hasHide) {
                final originalDirective = importInfo.directive.toSource();
                final uriEnd = originalDirective.indexOf("'", originalDirective.indexOf("'") + 1) + 1;
                final combinator = originalDirective.substring(uriEnd);
                builder.write(combinator);
              } else {
                builder.write(';');
              }
              
              builder.writeln();
              lastCategory = category;
            }
          },
        );
      });
    });
  }
}
