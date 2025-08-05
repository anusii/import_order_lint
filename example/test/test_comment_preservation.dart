// Test file for comment preservation in import ordering
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

import 'package:flutter/material.dart';

import 'package:example/models/user.dart';

// This comment should move with the import below (no empty line)
import 'package:example/widgets/session_widget.dart';

import 'package:notepod/notepod.dart';

// Comment to test import_order_lint
import 'package:notepod/utils/is_desktop.dart';

// Multi-line comment
// that should move with the import
import 'package:solidpod/solidpod.dart'
    show
      GrantPermissionUrl,
      getWebId,
      readPod;

import 'package:window_manager/window_manager.dart';

// void main() {
//   print('Testing comment preservation in import ordering');
// } 
