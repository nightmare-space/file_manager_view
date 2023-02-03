import 'dart:io';

import 'package:file_manager_view/core/io/document/document.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';

import 'config/config.dart';
import 'core/server/file_server.dart';
import 'v2/file_manager.dart';

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
  localAddress().then((value){
    print('------>$value');
  });
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
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  String get urlPrefix {
    Uri? uri = Uri.tryParse(url);
    String perfix = 'http://${uri!.host}:${Config.port}';
    if (kIsWeb && kDebugMode) {
      perfix = 'http://192.168.140.102:20000';
    }
    return perfix;
  }

  Future<String> getPath() async {
    // Directory tempDir = await getLibraryDirectory();
    Directory tempDir = await getLibraryDirectory();
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
            home: FileManager(
              address: urlPrefix,
              path: snapshot.data!,
              drawer: false,
            ),
          );
        }
        return SizedBox();
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
