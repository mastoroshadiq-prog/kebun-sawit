# Quick Reference - MVC Libs

## 🚀 ConnectionUtils

Utility untuk koneksi dan error handling.

### Import
```dart
import 'package:kebun/mvc_libs/connection_utils.dart';
```

### Cek Koneksi Internet
```dart
if (await ConnectionUtils.checkConnection()) {
  print("Online 🟢");
} else {
  print("Offline 🔴");
}
```

### Handle Error Message
```dart
try {
  // ... code that might throw error
} catch (e) {
  final utils = ConnectionUtils();
  
  // 1. Parse SQL Error
  String msg = utils.parseSqlError(e.toString());
  
  // 2. Get Friendly Message from Code
  String statusMsg = utils.handleErrorStatus("404");
}
```

### Common Error Codes
| Code | Meaning |
|------|---------|
| 401 | Unauthorized (Login ulang) |
| 404 | Not Found |
| 408 | Timeout |
| 409 | Conflict (Duplicate) |
| 500 | Server Error |
