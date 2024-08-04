import 'package:app_manager/app_manager.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/core/io/interface/io.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:file_manager_view/widgets/file_manager_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'app_select.dart';

/// Created By Nightmare on 2021/7/20
/// 文件选择组件
class FileSelectPage extends StatefulWidget {
  FileSelectPage({Key? key, this.path}) : super(key: key) {
    if (RuntimeEnvir.packageName != Config.packageName &&
        !GetPlatform.isDesktop) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = 'packages/file_manager_view/';
    }
  }
  final String? path;

  @override
  State createState() => _FileSelectPageState();
}

class _FileSelectPageState extends State<FileSelectPage> {
  FileSelectController clipboardController = Get.put(FileSelectController());
  PageController pageController = PageController();
  int page = 0;
  @override
  void initState() {
    super.initState();
    clipboardController.clearCheck();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 6.w,
              ),
              child: DetailsTab(
                value: page,
                controller: pageController,
                onChange: (value) {
                  page = value;
                  setState(() {});
                  pageController.animateToPage(
                    page,
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    curve: Curves.ease,
                  );
                },
              ),
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                children: [
                  FileManager(
                    // 应该是一个成功启动的port
                    address: 'http://127.0.0.1:${Config.port}',
                    path: widget.path ?? '/sdcard',
                    windowType: WindowType.selectFile,
                    usePackage: true,
                  ),
                  const AppSelect(),
                ],
              ),
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
                          List<String> paths = [];
                          for (FileEntity value
                              in clipboardController.checkNodes) {
                            paths.add(value.path);
                          }
                          // TODO bug
                          try {
                            CheckController checkContainer = Get.find();
                            for (AppInfo? value in checkContainer.check) {
                              paths.add(value!.sourceDir);
                            }
                            checkContainer.clearCheck();
                          } catch (e) {}
                          Navigator.of(context).pop(paths);
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
      ),
    );
  }
}

final List<String> tabs = [
  '文件选择',
  '应用选择',
];

class DetailsTab extends StatefulWidget {
  const DetailsTab({
    Key? key,
    this.value,
    this.onChange,
    this.controller,
  }) : super(key: key);
  final int? value;
  final void Function(int value)? onChange;
  final PageController? controller;

  @override
  _DetailsTabState createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  int? _value;
  @override
  void initState() {
    super.initState();
    _value = widget.value;
    widget.controller!.addListener(() {
      if (widget.controller!.page!.round() != _value) {
        _value = widget.controller!.page!.round();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color accent = Theme.of(context).primaryColor;
    List<Widget> children = [];
    for (int i = 0; i < tabs.length; i++) {
      bool isCheck = _value == i;
      children.add(
        GestureDetector(
          onTap: () {
            widget.onChange!(i);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCheck ? accent : accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Text(
              tabs[i],
              style: TextStyle(
                color: isCheck ? Colors.white : accent,
                fontSize: 16.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: children,
      ),
    );
  }
}
