#!/usr/bin/env dart
// Import Order Tool - entry point
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
import 'package:yaml/yaml.dart';

import 'fix_imports.dart' as fix_imports_impl;

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Print usage information')
    ..addFlag('verbose',
        abbr: 'v', negatable: false, help: 'Show verbose output')
    ..addFlag('set-exit-if-changed',
        negatable: false,
        help:
            'Return exit code 1 if imports would be changed (like dart format)')
    ..addFlag('check',
        abbr: 'c',
        negatable: false,
        help:
            'Check import ordering without fixing (same as --set-exit-if-changed)')
    ..addFlag('dry-run', negatable: false, help: 'Same as --check')
    ..addOption('project-name',
        help:
            'Explicitly set the project name (auto-detected from pubspec.yaml by default)');

  try {
    final argResults = parser.parse(args);

    if (argResults['help'] as bool) {
      _printUsage(parser);
      exit(0);
    }

    // Get paths from arguments, default to 'lib' if none provided.

    List<String> filePaths = argResults.rest;
    if (filePaths.isEmpty) {
      filePaths = ['lib'];
    }

    // Auto-detect project name if not provided.

    String? projectName = argResults['project-name'] as String?;
    if (projectName == null) {
      projectName = _getProjectNameFromPubspec(Directory.current.path);
      if (projectName.isEmpty) {
        print('⚠️  Could not auto-detect project name from pubspec.yaml');
        print('   Use --project-name=<name> to specify explicitly');
      }
    }

    // Convert our simplified args to the full fix_imports format.

    final newArgs = <String>[];

    if (argResults['verbose'] as bool) newArgs.add('--verbose');
    if (argResults['set-exit-if-changed'] as bool ||
        argResults['check'] as bool ||
        argResults['dry-run'] as bool) {
      newArgs.add('--set-exit-if-changed');
    }
    if (projectName.isNotEmpty) {
      newArgs.addAll(['--project-name', projectName]);
    }

    // Always recursive since we're defaulting to directories.
    newArgs.add('--recursive');

    // Add the paths.

    newArgs.addAll(filePaths);

    // Call the existing implementation.

    fix_imports_impl.main(newArgs);
  } catch (e) {
    print('Error: $e');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('''
import_order - Fix and check import ordering in Dart files.

Usage: dart run import_order [options] [paths]

If no paths are specified, defaults to checking the 'lib' directory.
Project name is auto-detected from pubspec.yaml unless --project-name is specified.

${parser.usage}

Examples:
  # Check import ordering in lib directory (default)
  dart run import_order --set-exit-if-changed
  
  # Check specific directories
  dart run import_order --set-exit-if-changed lib test
  
  # Fix import ordering in lib directory
  dart run import_order
  
  # Check with verbose output
  dart run import_order --set-exit-if-changed -v
  
  # Specify project name explicitly  
  dart run import_order --project-name=moviestar --set-exit-if-changed

CI/CD Usage:
  Similar to dart format --set-exit-if-changed, this tool returns:
  • Exit code 0: No changes needed (CI passes)
  • Exit code 1: Import issues found (CI fails)
''');
}

// Gets the package name from the project's pubspec.yaml file.

String _getProjectNameFromPubspec(String projectPath) {
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
