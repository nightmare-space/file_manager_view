import 'dart:convert';
import 'dart:io';

import 'package:file_manager_view/core/io/impl/directory_unix.dart';
import 'package:file_manager_view/utils/shelf/static_handler.dart';
import 'package:get/utils.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';

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
      String path = request.requestedUri.queryParameters['path'];
      String name = request.requestedUri.queryParameters['name'];
      File(path).rename(dirname(path) + '/' + name);
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    app.get('/delete', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path'];
      File(path).delete();
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    app.get('/getdir', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path'];
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.json.toString();
      List<String> full = await getFullMessage(path);
      return Response.ok(
        jsonEncode(full),
        headers: corsHeader,
      );
    });
    app.mount('/', (request) => handler(request));
    HttpServer server = await io.serve(
      app,
      InternetAddress.anyIPv4,
      20000,
      shared: true,
    );
  }
}

Future<String> execCmd(
  String cmd, {
  bool throwException = true,
}) async {
  final List<String> args = cmd.split(' ');
  ProcessResult execResult;
  if (Platform.isWindows) {
    execResult = await Process.run(
      RuntimeEnvir.binPath + Platform.pathSeparator + args[0],
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
