import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart';
import 'package:file_manager_view/core/io/document/document.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';

import 'config/config.dart';
import 'core/server/file_server.dart';
import 'v2/file_manager.dart';
import 'widgets/file_manager_controller.dart';

Future<void> main() async {
  // debugPaintLayerBordersEnabled = true; // 显示层级边界÷
  if (!GetPlatform.isWeb && !GetPlatform.isIOS) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  }
  runApp(const MyApp());
  StatusBarUtil.transparent();
  if (!GetPlatform.isWeb) {
    await Server.start();
  }
  localAddress().then((value) {
    print('------>$value');
  });
  Dio().get('http://www.baidu.com');
}

Future<List<String>> localAddress() async {
  List<String> address = [];
  final List<NetworkInterface> interfaces = await NetworkInterface.list(
    includeLoopback: false,
    type: InternetAddressType.IPv4,
  );
  for (final NetworkInterface netInterface in interfaces) {
    // Log.i('netInterface name -> ${netInterface.name}');
    // 遍历网卡
    for (final InternetAddress netAddress in netInterface.addresses) {
      // 遍历网卡的IP地址

      address.add(netAddress.address);
    }
  }
  return address;
}

String get urlPrefix {
  Uri? uri = Uri.tryParse(url);
  String perfix = 'http://${uri!.host}:${Config.port}';
  if (kIsWeb && kDebugMode) {
    perfix = 'http://192.168.168.27:30000';
  }
  return perfix;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<String> getPath() async {
    // Directory tempDir = await getLibraryDirectory();

    Directory tempDir = Directory('/sdcard');
    if (GetPlatform.isIOS) {
      tempDir = await getLibraryDirectory();
    }
    String tempPath = tempDir.path;
    return tempPath;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getPath(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GetMaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light().copyWith(),
            defaultTransition: Transition.fadeIn,
            home: FileDropWrapper(
              child: FileManager(
                address: urlPrefix,
                path: snapshot.data!,
                drawer: false,
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class FutureWrapper extends StatefulWidget {
  const FutureWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  State<FutureWrapper> createState() => _FutureWrapperState();
}

class _FutureWrapperState extends State<FutureWrapper> {
  bool isInit = false;
  Future<void> init() async {
    if (isInit) {
      return;
    }
    await Server.start();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Text('Input a URL to start');
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.active:
            return const Text('');
          case ConnectionState.done:
            return widget.child;
        }
      },
    );
  }
}

class FileDropWrapper extends StatefulWidget {
  const FileDropWrapper({
    required this.child,
    this.url,
  });
  final Widget child;
  final String? url;

  @override
  State<FileDropWrapper> createState() => _FileDropWrapperState();
}

class _FileDropWrapperState extends State<FileDropWrapper> {
  bool dropping = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DropTarget(
          onDragDone: (detail) async {
            Log.d('files -> ${detail.files}');
            if (GetPlatform.isAndroid) {
              for (var value in detail.files) {
                // Log.w(value.path);
                // String filePath = path.fromUri(Uri.parse(value.path).path).replaceAll(
                //       '/raw/',
                //       '',
                //     );
                // controller.sendFileFromPath(filePath);
                // Log.w(p
                //     .fromUri(Uri.parse(value.path).path)
                //     .replaceAll('/raw/', ''));
              }
            }
            FileManagerController fileManagerController = Get.find();
            setState(() {});
            if (detail.files.isNotEmpty) {
              for (XFile xFile in detail.files) {
                try {
                  Log.e('name -> ${xFile.name}');
                  Log.e('path -> ${fileManagerController.dir.path}');
                  String base64Name = base64Encode(utf8.encode(xFile.name!));
                  Log.w(base64Name);
                  Response response2 = await Dio().post<String>(
                    '${widget.url ?? urlPrefix}/file_upload',
                    data: xFile.openRead(),
                    onSendProgress: (count, total) {
                      Log.v('count:$count total:$total pro:${count / total}');
                    },
                    options: Options(
                      headers: {
                        Headers.contentLengthHeader: await xFile.length(),
                        HttpHeaders.contentTypeHeader: ContentType.binary.toString(),
                        'filename': xFile.name,
                        'path': fileManagerController.dir.path,
                      },
                    ),
                  );
                  fileManagerController.updateFileNodes();
                  Log.w(response2);
                } catch (e) {
                  Log.e('Web 上传文件出错 : $e');
                }
              }
            }
          },
          onDragUpdated: (details) {
            setState(() {
              // offset = details.localPosition;
            });
          },
          onDragEntered: (detail) {
            setState(() {
              dropping = true;
              // offset = detail.localPosition;
            });
          },
          onDragExited: (detail) {
            setState(() {
              dropping = false;
              // offset = null;
            });
          },
          child: widget.child,
        ),
        if (dropping)
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4.0,
              sigmaY: 4.0,
            ),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Text(
                  '释放以上传文件到这个文件夹~',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.w,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
