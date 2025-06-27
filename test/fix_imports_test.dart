import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as path;

/// Comprehensive tests for the import order fixing logic.
///
/// These tests cover various scenarios including:
/// - Basic import ordering (dart, flutter, external, project, relative)
/// - Multi-line imports with show/hide clauses
/// - Mixed complex scenarios
/// - Regression test for code duplication bug (#9)
/// - Edge cases

late Directory tempDir;

void main() {
  setUpAll(() async {
    // Create temporary directory for test files
    tempDir = await Directory.systemTemp.createTemp('import_order_test_');

    // Create a mock pubspec.yaml for project name detection
    final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
    await pubspecFile.writeAsString('''
name: test_project
version: 1.0.0
dependencies:
  flutter:
    sdk: flutter
''');
  });

  tearDownAll(() async {
    // Clean up temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Import Order Fixing Tests', () {
    test('Basic import ordering - all categories', () async {
      const input = '''
import 'package:test_project/models/user.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import '../utils/helper.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}
''';

      const expected = '''
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart';
import 'package:path/path.dart';

import 'package:test_project/models/user.dart';

import '../utils/helper.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}
''';

      await _testImportFixWithBinary(input, expected, 'basic_ordering');
    });

    test('Multi-line imports with show clauses', () async {
      const input = '''
import 'package:flutter/material.dart' show
    Widget,
    StatefulWidget,
    State;
import 'dart:async';
import 'package:test_project/constants.dart' show
    APP_NAME,
    VERSION;

class MyApp extends StatefulWidget {}
''';

      const expected = '''
import 'dart:async';

import 'package:flutter/material.dart' show
    Widget,
    StatefulWidget,
    State;

import 'package:test_project/constants.dart' show
    APP_NAME,
    VERSION;

class MyApp extends StatefulWidget {}
''';

      await _testImportFixWithBinary(input, expected, 'multiline_show');
    });

    test('Multi-line imports with hide clauses', () async {
      const input = '''
import 'package:test_project/widgets.dart' hide
    OldWidget,
    DeprecatedComponent;
import 'package:flutter/material.dart';
import 'package:http/http.dart' hide
    Client;

void main() {}
''';

      const expected = '''
import 'package:flutter/material.dart';

import 'package:http/http.dart' hide
    Client;

import 'package:test_project/widgets.dart' hide
    OldWidget,
    DeprecatedComponent;

void main() {}
''';

      await _testImportFixWithBinary(input, expected, 'multiline_hide');
    });

    test('Regression test for code duplication bug (#9)', () async {
      const input = '''
import 'package:flutter/material.dart';

import 'package:test_project/constants/health_data_type.dart';
import 'package:test_project/features/survey/form_state.dart';
import 'package:test_project/features/survey/input_fields/categorical_input.dart';
import 'package:test_project/features/survey/input_fields/date_input.dart';
import 'package:test_project/features/survey/input_fields/number_input.dart';
import 'package:test_project/features/survey/input_fields/text_input.dart';
import 'package:test_project/features/survey/question.dart';
import 'package:test_project/features/survey/utils/get_icon_colour.dart';
import 'package:test_project/features/survey/utils/get_question_icon.dart';

/// A widget that builds and manages a dynamic health survey form.
///
/// This form displays various types of input fields, handles focus management,
/// and submits user responses.

class HealthSurveyForm extends StatefulWidget {
  /// List of survey questions to be displayed in the form.

  final List<HealthSurveyQuestion> questions;

  /// Callback function to handle form submission.

  final void Function(Map<String, dynamic> responses) onSubmit;

  /// Customizable submit button text.

  final String submitButtonText;
}
''';

      const expected = '''
import 'package:flutter/material.dart';

import 'package:test_project/constants/health_data_type.dart';
import 'package:test_project/features/survey/form_state.dart';
import 'package:test_project/features/survey/input_fields/categorical_input.dart';
import 'package:test_project/features/survey/input_fields/date_input.dart';
import 'package:test_project/features/survey/input_fields/number_input.dart';
import 'package:test_project/features/survey/input_fields/text_input.dart';
import 'package:test_project/features/survey/question.dart';
import 'package:test_project/features/survey/utils/get_icon_colour.dart';
import 'package:test_project/features/survey/utils/get_question_icon.dart';

/// A widget that builds and manages a dynamic health survey form.
///
/// This form displays various types of input fields, handles focus management,
/// and submits user responses.

class HealthSurveyForm extends StatefulWidget {
  /// List of survey questions to be displayed in the form.

  final List<HealthSurveyQuestion> questions;

  /// Callback function to handle form submission.

  final void Function(Map<String, dynamic> responses) onSubmit;

  /// Customizable submit button text.

  final String submitButtonText;
}
''';

      await _testImportFixWithBinary(input, expected, 'regression_duplication');
    });

    test('Complex multi-line imports with mixed show/hide', () async {
      const input = '''
import 'package:test_project/widgets.dart' show
    CustomButton,
    CustomCard hide
    OldButton;
import 'dart:convert' show
    json,
    base64 hide
    latin1;
import 'package:flutter/material.dart';

class MyWidget {}
''';

      const expected = '''
import 'dart:convert' show
    json,
    base64 hide
    latin1;

import 'package:flutter/material.dart';

import 'package:test_project/widgets.dart' show
    CustomButton,
    CustomCard hide
    OldButton;

class MyWidget {}
''';

      await _testImportFixWithBinary(input, expected, 'complex_multiline');
    });

    test('File with only dart imports', () async {
      const input = '''
import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() {}
''';

      const expected = '''
import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() {}
''';

      await _testImportFixWithBinary(input, expected, 'dart_only');
    });

    test('Already correctly ordered imports', () async {
      const input = '''
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart';

import 'package:test_project/models/user.dart';

import '../utils/helper.dart';

class MyWidget {}
''';

      // Should remain unchanged since imports are already correctly ordered
      await _testImportFixWithBinary(input, input, 'already_ordered');
    });

    test('Imports with as clauses', () async {
      const input = '''
import 'package:path/path.dart' as path;
import 'dart:math' as math;
import 'package:flutter/material.dart' as material;
import 'package:test_project/utils.dart' as utils;

void main() {}
''';

      const expected = '''
import 'dart:math' as math;

import 'package:flutter/material.dart' as material;

import 'package:path/path.dart' as path;

import 'package:test_project/utils.dart' as utils;

void main() {}
''';

      await _testImportFixWithBinary(input, expected, 'with_as_clauses');
    });

    test('File with no code duplication - ensures fix works', () async {
      // This test specifically validates that the class definition only appears once
      const input = '''
import 'package:flutter/material.dart';
import 'package:test_project/models/user.dart';

/// Documentation comment
class MyClass {
  final String name;
  MyClass(this.name);
}
''';

      const expected = '''
import 'package:flutter/material.dart';

import 'package:test_project/models/user.dart';

/// Documentation comment
class MyClass {
  final String name;
  MyClass(this.name);
}
''';

      final result =
          await _testImportFixWithBinary(input, expected, 'no_duplication');

      // Additional check: ensure class definition appears exactly once
      final classCount = RegExp(r'class MyClass \{').allMatches(result).length;
      expect(classCount, equals(1),
          reason:
              'Class definition should appear exactly once, found $classCount instances');
    });
  });
}

/// Helper method to test import fixing using the binary executable
Future<String> _testImportFixWithBinary(
    String input, String expected, String testName) async {
  // Create test file in temp directory with pubspec.yaml
  final testFile = File(path.join(tempDir.path, '${testName}.dart'));
  await testFile.writeAsString(input);

  // Run the import fixer binary from the bin directory
  final scriptPath =
      path.join(Directory.current.path, 'bin', 'fix_imports.dart');
  final result = await Process.run(
    'dart',
    [
      'run',
      scriptPath,
      '--project-name=test_project',
      testFile.path,
    ],
  );

  // Check that the process completed successfully
  expect(result.exitCode, equals(0),
      reason:
          'Import fixer failed with exit code ${result.exitCode}.\nStdout: ${result.stdout}\nStderr: ${result.stderr}');

  // Read the result and compare
  final actualContent = await testFile.readAsString();
  expect(actualContent.trim(), equals(expected.trim()),
      reason:
          'Import ordering did not match expected result for test: $testName\n\nActual:\n$actualContent\n\nExpected:\n$expected');

  return actualContent;
}
