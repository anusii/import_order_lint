// Test cases for multi-line imports.
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

/// TEST CASE 1: Simple multi-line show clause.

// import 'package:flutter/widgets.dart'
//     show
//       Container,
//       Row,
//       Column;

/// TEST CASE 2: Multi-line show clause with comments.

// import 'package:flutter/material.dart'
//     show
//       // Core widgets
//       MaterialApp,
//       Scaffold,
//       // Layout widgets
//       Center,
//       Padding;

/// TEST CASE 3: Multi-line show clause with different indentation.

// import 'package:flutter/services.dart'
//     show
//   SystemChrome,
//   SystemUiOverlayStyle,
//   Brightness;

/// TEST CASE 4: Multi-line show clause with trailing semicolon.

// import 'package:flutter/rendering.dart'
//     show
//       BoxConstraints,
//       RenderBox,
//       RenderObject,
//       RenderSliver,
//       RenderView;

// TEST CASE 5: Multi-line show clause with complex formatting
// import 'package:flutter/foundation.dart'
//     show
//       // Debugging
//       debugPrint,
//       // Assertions
//       FlutterError,
//       // Diagnostics
//       DiagnosticsNode,
//       Diagnosticable,
//       DiagnosticableTree;

/// TEST CASE 6: Multi-line show clause with empty lines.

// import 'package:flutter/gestures.dart'
//     show
//       // Gesture recognizers
//       GestureRecognizer,
//       TapGestureRecognizer,
//       // Gesture detectors
//       GestureDetector;

/// TEST CASE 7: Multiple multi-line imports in different categories.

// import 'package:http/http.dart'
//     show
//       Client,
//       Response,
//       Request;

// import 'package:path/path.dart'
//     show
//       join,
//       dirname,
//       basename;

/// TEST CASE 8: Project imports with multi-line show clauses.

// import 'package:example/widgets/my_widget.dart'
//     show
//       MyWidget,
//       MyWidgetState;

// import 'package:example/utils/helpers.dart'
//     show
//       Helpers,
//       formatString;

/// A class to demonstrate the import order lint.

// class TestImports {
//   void testMethod() {
//     print('This is a test method');
//   }
// }
