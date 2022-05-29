import 'package:file_manager_view/core/io/document/document.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'config/config.dart';
import 'core/server/file_server.dart';
import 'v2/file_manager.dart';
Future<void> main() async {
  // debugPaintLayerBordersEnabled = true; // 显示层级边界÷
  if (!GetPlatform.isWeb) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  }
  runApp(const MyApp());
  StatusBarUtil.transparent();
  if (!GetPlatform.isWeb) {
    await Server.start();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  String get urlPrefix {
    Uri uri = Uri.tryParse(url);
    String perfix = 'http://${uri.host}:20000';
    if (kIsWeb && kDebugMode) {
      perfix = 'http://192.168.140.102:20000';
    }
    return perfix;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      defaultTransition: Transition.fadeIn,
      home: FileManager(
        address: urlPrefix,
      ),
    );
  }
}

class FutureWrapper extends StatefulWidget {
  const FutureWrapper({
    Key key,
    this.child,
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
        return const SizedBox();
      },
    );
  }
}
