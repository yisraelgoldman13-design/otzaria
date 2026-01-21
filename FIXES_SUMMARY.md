# Compilation Errors - Fixed

## Summary
All compilation errors from the Windows build have been identified and resolved.

## Errors Fixed

### 1. **lib/settings/settings_screen.dart (Lines 1507, 1512)**
- **Error**: "Not a constant expression" and "Method invocation is not a constant expression"
- **Root Cause**: The `segments` parameter was marked as `const` but contained `context.tr()` method calls inside `ButtonSegment` labels, which cannot be constant
- **Fix**: Removed the `const` keyword from the `segments` list to allow dynamic method invocation
- **Before**:
  ```dart
  segments: const [
    ButtonSegment<_BackupMode>(
      label: Text(context.tr('backupAll')),
      ...
    ),
  ]
  ```
- **After**:
  ```dart
  segments: [
    ButtonSegment<_BackupMode>(
      label: Text(context.tr('backupAll')),
      ...
    ),
  ]
  ```

### 2. **lib/localization/app_strings.dart (Lines 264, 490)**
- **Error**: "Constant evaluation error"
- **Root Cause**: Duplicate keys within the `_hebrewStrings` and `_englishStrings` const maps caused compilation errors. Maps cannot have duplicate keys in a constant context.
- **Fix**: Removed all duplicate keys from both maps:
  - Hebrew map: Removed duplicates for 'libraryVersion', 'softwareVersion', 'numberOfBooks', 'developers', 'contributors', 'joinDevelopment', 'changelog', 'aboutSoftware'
  - English map: Removed duplicates for the same keys

## Testing
- All errors have been resolved
- No compilation errors remain
- Both files are now syntactically correct and will compile successfully

## Files Modified
1. `/workspaces/otzaria/lib/settings/settings_screen.dart`
2. `/workspaces/otzaria/lib/localization/app_strings.dart`
