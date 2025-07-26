# Import Order Lint - Example Project

This example demonstrates how to use the **import_order_lint** standalone tool to organize imports in your Dart/Flutter project.

## 🎯 Quick Demo

This project contains test files with commented-out imports that you can uncomment to test the tool's capabilities.

### Test Files Available
- `test/test_comments.dart` - Basic import ordering scenarios
- `test/test_multi_line_imports.dart` - Complex multi-line import statements  
- `test/test_rio_imports.dart` - Real-world import examples

**To test:** Uncomment some imports in the test files, then run the tool to see it detect and fix ordering issues!

### Check Import Ordering
```bash
# From the example directory, check import issues
dart run ../bin/import_order.dart --set-exit-if-changed

# Check specific test files
dart run ../bin/import_order.dart --set-exit-if-changed test/

# Or run from parent directory
dart run import_order_lint/bin/import_order.dart --set-exit-if-changed example/
```

### Fix Import Ordering  
```bash
# From the example directory, fix import issues
dart run ../bin/import_order.dart

# Fix specific test files
dart run ../bin/import_order.dart test/

# Or run from parent directory  
dart run import_order_lint/bin/import_order.dart example/
```

## 🚀 Key Features Demonstrated

- ✅ **Auto-detection**: Tool automatically detects project name from `pubspec.yaml`
- ✅ **Smart defaults**: Defaults to `lib` directory when no path specified
- ✅ **CI/CD ready**: Use `--set-exit-if-changed` for build pipelines
- ✅ **No plugin needed**: Works as standalone tool, no `custom_lint` dependency required

## 🔧 No Setup Required

Unlike the old custom_lint plugin approach:
- ❌ **No** `custom_lint` dependency in `pubspec.yaml`
- ❌ **No** `custom_lint` plugin in `analysis_options.yaml`  
- ✅ **Just run** the standalone tool when needed

## 📐 Import Order Rules

The tool organizes imports into these groups:
1. **Dart SDK imports** (`dart:*`)
2. **Flutter imports** (`package:flutter/*`)  
3. **External packages** (other `package:*`)
4. **Project imports** (`package:example/*`)
5. **Relative imports** (`../`, `./`)

Each group is alphabetically sorted with blank lines between groups.

## 🎬 Try It Out

Run the tool on this example project to see it organize the imports!
