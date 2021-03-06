import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';


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
  void initState() {
    super.initState();
    clipboardController.clearCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f7),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: NiIconButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          '选择文件',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: FileManager(
              address: 'http://127.0.0.1:20000',
              path: '/storage/emulated/0',
            ),
          ),
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: const Color(0xffebebed),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 160,
                        height: 42,
                        decoration: const BoxDecoration(),
                        child: const Center(
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
                      child: const SizedBox(
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
