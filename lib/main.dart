import 'package:file_manager_view/core/io/document/document.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:global_repository/global_repository.dart';

import 'config/config.dart';
import 'core/io/interface/directory.dart';
import 'core/io/interface/file_entity.dart';
import 'core/io/util/directory_factory.dart';
import 'core/server/file_server.dart';
import 'v2/home_page.dart';
import 'page/file_select_page.dart';

String get urlPrefix {
  Uri uri = Uri.tryParse(url);
  String perfix = 'http://${uri.host}:20000';
  if (kIsWeb && kDebugMode) {
    perfix = 'http://192.168.184.102:20000';
  }
  return perfix;
}

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
      home: const HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    PermissionUtil.requestStorage();
    init();
  }

  Future<void> init() async {
    Directory dir = DirectoryFactory.getPlatformDirectory('/sdcard');
    List<FileEntity> list = await dir.list();
    list.forEach((element) {
      Log.d(element);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FileSelectPage();
  }
}
