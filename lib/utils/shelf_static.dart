import 'dart:io';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

bool _started = false;

class ShelfStatic {
  static Future<void> start() async {
    if (_started) {
      return;
    }

    _started = true;
    String home = '';
    if (GetPlatform.isWindows) {
      // io.serve(
      //   createStaticHandler('C:\\', listDirectories: true),
      //   '0.0.0.0',
      //   Config.shelfPort,
      //   shared: true,
      // );
      // io.serve(
      //   createStaticHandler('D:\\', listDirectories: true),
      //   '0.0.0.0',
      //   Config.shelfPort,
      //   shared: true,
      // );

      return;
    } else if (GetPlatform.isDesktop) {
      home = '/';
    } else {
      home = '/sdcard';
    }
    // final virDirHandler = ShelfVirtualDirectory('/', showLogs: true).handler;
    var handler = createStaticHandler(
      home,
      listDirectories: true,
    );
    HttpServer server = await io.serve(
      handler,
      InternetAddress.anyIPv4,
      8000,
      shared: true,
    );
    Log.w('$server is start');
  }

  static void close() {}
}
