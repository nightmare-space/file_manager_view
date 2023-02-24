import 'dart:convert';
import 'dart:io';

import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/core/io/impl/directory_unix.dart';
import 'package:get/utils.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

var app = Router();
final corsHeader = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': '*',
  'Access-Control-Allow-Methods': '*',
  'Access-Control-Allow-Credentials': 'true',
};

class Server {
  // 启动文件管理器服务端
  static Future<void> start() async {
    var handler = createStaticHandler(
      GetPlatform.isMacOS ? '/Users' : '/',
      listDirectories: true,
    );
    app.get('/rename', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      String name = request.requestedUri.queryParameters['name']!;
      await File(path).rename(dirname(path) + '/' + name);
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    app.get('/delete', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      await File(path).delete();
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    app.get('/getdir', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.json.toString();
      List<String> full;
      if (Platform.isIOS) {
        full = await getIOSFullMessage(path);
      } else {
        full = await getFullMessage(path);
      }
      return Response.ok(
        jsonEncode(full),
        headers: corsHeader,
      );
    });
    app.get('/token', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      return Response.ok(
        'success',
        headers: corsHeader,
      );
    });
    app.mount('/', (request) => handler(request));
    // ignore: unused_local_variable
    HttpServer server = await io.serve(
      app,
      InternetAddress.anyIPv4,
      Config.port,
      shared: false,
    );
    print('File Serer start with ${InternetAddress.anyIPv4.address}:${Config.port}');
    HttpServer server2 = await HttpServer.bind(InternetAddress.anyIPv4, 30000);
    server2.listen((event) {
      print(event);
    });
  }

  // 启动文件管理器服务端
  static Router getFileServerHandler() {
    var handler = createStaticHandler(
      GetPlatform.isMacOS ? '/Users' : '/',
      listDirectories: true,
    );
    app.get('/rename', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      String name = request.requestedUri.queryParameters['name']!;
      await File(path).rename(dirname(path) + '/' + name);
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    app.get('/delete', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      await File(path).delete();
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    app.get('/getdir', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.json.toString();
      List<String> full = await getFullMessage(path);
      return Response.ok(
        jsonEncode(full),
        headers: corsHeader,
      );
    });
    app.mount('/', (request) => handler(request));
    // ignore: unused_local_variable
    return app;
  }
}

String _twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

String wrapSpace(String itemNumber, String size) {
  return ('$itemNumber $size').padRight(10);
}

extension TimeExt on DateTime {
  String fmTime() {
    StringBuffer buffer = StringBuffer();
    buffer.write('$year-${_twoDigits(month)}-${_twoDigits(day)} ');
    buffer.write('${_twoDigits(hour)}:${_twoDigits(minute)}');
    return buffer.toString();
  }
}

Future<List<String>> getIOSFullMessage(String path) async {
  List<String> message = [];
  for (final FileSystemEntity fileSystemEntity in Directory(path).listSync()) {
    print('fileSystemEntity -> $fileSystemEntity');
    if (fileSystemEntity is Directory) {
      StringBuffer buffer = StringBuffer();
      FileStat stat = fileSystemEntity.statSync();
      buffer.write('d${stat.modeString()} ');
      buffer.write(wrapSpace('0', stat.size.toString()));
      buffer.write('${stat.modified.fmTime()} ');
      buffer.write('${basename(fileSystemEntity.path)}');
      message.add(buffer.toString());
      // message.add('value')
    } else {
      StringBuffer buffer = StringBuffer();
      FileStat stat = fileSystemEntity.statSync();
      buffer.write('-${stat.modeString()} ');
      // buffer.write('0 ');
      // buffer.write('${stat.size} ');
      buffer.write(wrapSpace('0', stat.size.toString()));
      buffer.write('${stat.modified.fmTime()} ');
      buffer.write('${basename(fileSystemEntity.path)}');
      message.add(buffer.toString());
    }
  }
  return message;
}

Future<String> execCmd(
  String cmd, {
  bool throwException = true,
}) async {
  final List<String> args = cmd.split(' ');
  ProcessResult execResult;
  if (Platform.isWindows) {
    execResult = await Process.run(
      RuntimeEnvir.binPath! + Platform.pathSeparator + args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  } else {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  }
  if ('${execResult.stderr}'.isNotEmpty) {
    if (throwException) {
      Log.w('adb stderr -> ${execResult.stderr}');
      throw Exception(execResult.stderr);
    }
  }
  // Log.e('adb stdout -> ${execResult.stdout}');
  return execResult.stdout.toString().trim();
}
