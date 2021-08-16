import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import '../widgets/file_manager_controller.dart';
import '../widgets/file_manager_window.dart';

/// Created By Nightmare on 2021/7/20
/// 文件选择组件
class FileSelectPage extends StatefulWidget {
  FileSelectPage({Key key}) : super(key: key) {
    if (RuntimeEnvir.packageName != Config.packageName &&
        !GetPlatform.isDesktop) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = 'packages/file_manager_view/';
    }
  }

  @override
  _FileSelectPageState createState() => _FileSelectPageState();
}

class _FileSelectPageState extends State<FileSelectPage> {
  FileSelectController clipboardController = Get.put(FileSelectController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: NiIconButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: Text(
          '选择文件',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FileManagerWindow(
              windowType: WindowType.selectFile,
              initPath: '/storage/emulated/0',
            ),
          ),
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Color(0xffebebed),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 160,
                        height: 42,
                        decoration: BoxDecoration(),
                        child: Center(
                          child: Text(
                            '取消',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(
                          clipboardController.checkNodes,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 160,
                        height: 42,
                        child: Center(
                          child: Text(
                            '确定',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
