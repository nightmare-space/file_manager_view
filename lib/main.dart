import 'package:file_manager_view/core/io/document/document.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'config/config.dart';
import 'core/io/interface/directory.dart';
import 'core/io/interface/file_entity.dart';
import 'core/io/util/directory_factory.dart';
import 'core/server/file_server.dart';
import 'utils/shelf_static.dart';
import 'v2/file_manager.dart';
import 'page/file_select_page.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff57affc),
        ),
      ),
      defaultTransition: Transition.fadeIn,
      home:  FileManager(
        address: urlPrefix,
      ),
    );
  }
}
