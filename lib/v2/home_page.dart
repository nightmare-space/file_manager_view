import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/core/io/extension/extension.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:file_manager_view/widgets/file_manager_list_view.dart';
import 'package:file_manager_view/widgets/file_manager_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FileSelectController fileSelectController = Get.put(FileSelectController());
  FileManagerController fileManagerController = Get.put(
    FileManagerController('/sdcard'),
  );
  String path = '/sdcard';
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? OverlayStyle.light
          : OverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xfff3f4f9),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48.w,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new),
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: const Icon(Icons.arrow_forward_ios),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Container(
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: const Text(
                                '/ sdcard ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: const Icon(Icons.apps),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.w),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 240.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DrawerItem(
                            title: '根目录',
                            iconData: Icons.home,
                            groupValue: path,
                            value: '/sdcard',
                            onTap: (_) {
                              path = _;
                              fileManagerController.updateFileNodes(path);
                              setState(() {});
                            },
                          ),
                          DrawerItem(
                            title: '文档',
                            iconData: Icons.home,
                            groupValue: path,
                            value: '/sdcard/Documents',
                            onTap: (_) {
                              path = _;
                              fileManagerController.updateFileNodes(path);
                              setState(() {});
                            },
                          ),
                          DrawerItem(
                            title: '下载',
                            iconData: Icons.home,
                            groupValue: path,
                            value: '/sdcard/Download',
                            onTap: (_) {
                              path = _;
                              fileManagerController.updateFileNodes(path);
                              setState(() {});
                            },
                          ),
                          DrawerItem(
                            title: '回收站',
                            iconData: Icons.ac_unit_rounded,
                            groupValue: path,
                            value: '2',
                            onTap: (_) {},
                          ),
                          SizedBox(height: 12.w),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: const Text(
                              '设备',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.w),
                          DrawerItem(
                            title: '外置储存',
                            iconData: Icons.home,
                            value: '2',
                            onTap: (_) {},
                          ),
                          DrawerItem(
                            title: '系统',
                            iconData:
                                Icons.sentiment_very_dissatisfied_outlined,
                            value: '2',
                            onTap: (_) {},
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: FileManagerListView(
                          key: Key(path),
                          itemOnTap: (entity) {
                            if (entity.name == '..') {
                              fileManagerController.updateFileNodes(
                                dirname(fileManagerController.dirPath),
                              );
                            } else {
                              fileManagerController
                                  .updateFileNodes(entity.path);
                            }
                          },
                          itemOnLongPress: (entity) {},
                          controller: fileManagerController,
                          windowType: WindowType.defaultType,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    Key key,
    this.title,
    this.onTap,
    this.value,
    this.groupValue,
    this.iconData,
  }) : super(key: key);
  final String title;
  final void Function(String value) onTap;
  final String value;
  final String groupValue;
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    final bool isChecked = value == groupValue;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: InkWell(
        onTap: () => onTap(value),
        canRequestFocus: false,
        onTapDown: (_) {
          Feedback.forLongPress(context);
        },
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 48.w,
              decoration: isChecked
                  ? BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.w),
                    )
                  : null,
            ),
            SizedBox(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.w,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconData ?? Icons.open_in_new,
                        size: 18.w,
                        color: isChecked
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onBackground,
                      ),
                      SizedBox(
                        width: Dimens.gap_dp8,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: isChecked
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.onBackground,
                          fontSize: 14.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
