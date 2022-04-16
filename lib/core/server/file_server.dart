import 'dart:convert';
import 'dart:io';

import 'package:global_repository/global_repository.dart';
import 'package:signale/signale.dart';

class Server {
  static Future<void> start() async {
    HttpServer requestServer = await HttpServer.bind(
      InternetAddress.anyIPv4,
      20000,
      shared: true,
    );
//HttpServer.bind(主机地址，端口号)
//主机地址：InternetAddress.loopbackIPv4和InternetAddress.loopbackIPv6都可以监听到
    Log.v('监听 localhost地址，端口号为${requestServer.port}');
    //监听请求
    await for (final HttpRequest request in requestServer) {
      request.uri;
      switch (request.uri.path) {
        case '/getdir':
          Log.i(request.uri.queryParameters);
          String path = request.uri.queryParameters['path'];
          
          String lsPath = 'ls';
          // if (Platform.isAndroid) {
          //   lsPath = '/system/bin/ls';
          // }
          // --------------------------------------
          List<String> fullmessage = <String>[];
          path = path.replaceAll('//', '/');
          // 获得ls命令的输出
          final String lsOut = await exec(
            '$lsPath -aog "$path"\n',
          );
          lsOut.split('\n').forEach((element) {
            Log.d(element);
          });
          // 删除第一行 -> total xxx
          fullmessage = lsOut.split('\n')..removeAt(0);
          // ------------------------------------------------------------------------
          // ------------------------- 不要动这段代码，阿弥陀佛。-------------------------
          // linkFileNode 是当前文件节点有符号链接的情况。
          String linkFileNode = '';
          for (int i = 0; i < fullmessage.length; i++) {
            if (fullmessage[i].startsWith('l')) {
              //说明这个节点是符号链接
              if (fullmessage[i].split(' -> ').last.startsWith('/')) {
                //首先以 -> 符号分割开，last拿到的是该节点链接到的那个元素
                //如果这个元素不是以/开始，则该符号链接使用的是相对链接
                linkFileNode += fullmessage[i].split(' -> ').last + '\n';
              } else {
                linkFileNode += '$path/${fullmessage[i].split(' -> ').last}\n';
              }
            }
          }
          linkFileNode.split('\n').forEach((element) {});

          //
          if (linkFileNode.isNotEmpty) {
            // 当当前文件夹存在包含符号链接的节点时
            //-g取消打印owner  -0取消打印group   -L不跟随符号链接，会指向整个符号链接最后指向的那个
            final String lsOut = await exec(
              'echo "$linkFileNode"|xargs $lsPath -ALdog\n',
            );
            final List<String> linkFileNodes =
                lsOut.replaceAll('//', '/').split('\n');

            Log.i('====>$linkFileNodes');

            // 文件名到文件类型的 map
            // 例如 tmp:d
            // 类型是tag，'d'->文件夹，'l'->符号链接，'-'->普通文件
            final Map<String, String> map = <String, String>{};
            for (final String str in linkFileNodes) {
              // print(str);
              final String key = str.replaceAll(RegExp('^.*[0-9] /'), '/');
              Log.i('key->$key');
              map[key] = str.substring(0, 1);
            }
            Log.i('====>$map');

            for (int i = 0; i < fullmessage.length; i++) {
              final String linkFromFile = fullmessage[i].split(' -> ').last;

              Log.i('linkFromFile====>$linkFromFile');

              Log.i('map.keys->${map.keys}');
              Log.i('map.keys->${map.keys.contains(linkFromFile)}');
              if (map.keys.contains(linkFromFile)) {
                fullmessage[i] = fullmessage[i].replaceAll(
                    RegExp('^l'), map[fullmessage[i].split(' -> ').last]);
                // f.remove(f.first);r
              }
            }
          }
          request.response
            ..headers.add('Access-Control-Allow-Origin', '*')
            ..headers.add('Access-Control-Allow-Headers', '*')
            ..headers.add('Access-Control-Allow-Methods', '*')
            ..headers.add('Access-Control-Allow-Credentials', 'true')
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode(fullmessage))
            ..close();
          break;
        default:
      }
    }
  }
}

class ProcessServer {
  static HttpServer requestServer;
  static Future<void> start() async {
    requestServer = await HttpServer.bind(
      InternetAddress.anyIPv4,
      8000,
      shared: true,
    );
//HttpServer.bind(主机地址，端口号)
//主机地址：InternetAddress.loopbackIPv4和InternetAddress.loopbackIPv6都可以监听到
    Log.v('监听 localhost地址，端口号为${requestServer.port}');
    //监听请求
    await for (final HttpRequest request in requestServer) {
      //监听到请求后response回复它一个Hello World!然后关闭这个请求
      handleMessage(request);
    }
  }

  static void close() {
    requestServer?.close();
  }
}

void handleMessage(HttpRequest request) {
  try {
    if (request.method == 'GET') {
      //获取到GET请求

      handleGET(request);
    } else if (request.method == 'POST') {
      handleGET(request);
      //获取到POST请求

    } else if (request.method == 'OPTIONS') {
      handleGET(request);
      //获取到POST请求

    } else {
      //其它的请求方法暂时不支持，回复它一个状态
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..write('对不起，不支持${request.method}方法的请求！')
        ..close();
    }
  } catch (e) {
    Log.v('出现了一个异常，异常为：$e');
  }
  Log.v('请求被处理了');
}

Future<void> handleGET(HttpRequest request) async {
  String cmdline = '';
  request.headers.forEach(
    (name, values) {
      if (name == 'cmdline') {
        cmdline = values.first;
      }
    },
  );
  Log.v('cmdline ->$cmdline');
  // ProcessResult result = Process.runSync('sh', ['-c', cmdline]);
  // print('resultstdout -> ${result.stdout}');
  // print('resultstderr -> ${result.stderr}');
  // String result = await YanProcess().exec(cmdline);
  // request.response
  //   ..headers.add('Access-Control-Allow-Origin', '*')
  //   ..headers.add('Access-Control-Allow-Headers', '*')
  //   ..headers.add('Access-Control-Allow-Methods', '*')
  //   ..headers.add('Access-Control-Allow-Credentials', 'true')
  //   ..statusCode = HttpStatus.ok
  //   ..write(result)
  //   ..close();
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
