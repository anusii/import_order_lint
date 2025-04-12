// This file contains various multi-line import test cases to verify the fix works correctly

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