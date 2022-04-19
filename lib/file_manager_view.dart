export 'utils/file_manager.dart';
export 'v2/home_page.dart';
export 'core/server/file_server.dart';

import 'package:file_manager_view/core/io/document/document.dart';
import 'package:flutter/foundation.dart';

String getRemotePath(String path) {
  Uri uri = Uri.tryParse(url);
  String perfix = 'http://${uri.host}:8000$path';
  if (kIsWeb && kDebugMode) {
    perfix = 'http://192.168.184.102:8000$path';
  }
  return perfix.replaceAll('/sdcard', '');
}
