// Test file for import ordering with comments
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



// These are Dart core imports - INTENTIONALLY OUT OF ORDER for testing

import 'package:example/models/user.dart';

import 'package:example/widgets/session_widget.dart';

import 'package:riodm/riodm.dart';

import 'package:solidpod/solidpod.dart'
    // These are the exact functions we need
    show
        GrantPermissionUrl,
        getWebId,
        readPod;

import 'package:example/utils.dart';

// void main() {
//   print('Testing import ordering with comments preservation');
// }
