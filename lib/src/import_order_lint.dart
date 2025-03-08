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
import 'package:analyzer/error/error.dart' as analyzer;
import 'package:analyzer/error/listener.dart';
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
}
