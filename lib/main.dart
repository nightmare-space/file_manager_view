import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

import 'file_manager_view.dart';
import 'widgets/file_manager_controller.dart';
import 'widgets/file_manager_window.dart';
import 'page/file_select_page.dart';

void main() {
  // debugPaintLayerBordersEnabled = true; // 显示层级边界÷
  runApp(const MyApp());
  RuntimeEnvir.initEnvirWithPackageName('com.example.file_manager_view');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FileSelectPage(),
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
    Directory dir = Directory.getPlatformDirectory('/sdcard');
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
