// Test cases for Rio imports.
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

// TEST CASE 1: Dart SDK imports
// import 'dart:convert';
// import 'dart:async';

// TEST CASE 2: Flutter imports with package order
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// TEST CASE 3: External package with multi-line show clause
// import 'package:solidpod/solidpod.dart'
//     show
//       GrantPermissionUrl,
//       getWebId,
//       readPod;

// TEST CASE 4: External package with API endpoints
// import 'package:riodm/riodm.dart';
// import 'package:riopod/apis/rest_api.dart';

// TEST CASE 5: App-specific imports with different patterns
// import 'package:riopod/screens/app_screen.dart';
// import 'package:riopod/screens/session/tacs_tasks_initialise.dart';
// import 'package:riopod/widgets/loading_screen.dart';
// import 'package:riopod/constants/app.dart';

// TEST CASE 6: Multi-line show with comments and spacing
// import 'package:example/widgets/session_widget.dart'
//     show
//       // User session related
//       SessionWidget,
//       SessionState,

//       // Authentication related
//       AuthStatus,
//       LoginWidget;

// TEST CASE 7: Multiple show clauses with different styles
// import 'package:example/utils/permissions.dart'
//     show
//       PermissionHandler,
//       PermissionStatus;

// TEST CASE 8: Show clause with trailing comma and comment
// import 'package:example/models/user.dart'
//     show
//       User,
//       UserProfile,
//       UserSettings;  // End of user-related imports

/// A class to demonstrate the import order lint
// class TestImports extends ConsumerStatefulWidget {
//   const TestImports({super.key});

//   @override
//   ConsumerState<TestImports> createState() => TestImportsState();
// }

// class TestImportsState extends ConsumerState<TestImports> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
