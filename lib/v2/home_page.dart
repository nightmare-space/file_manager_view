import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/core/io/document/document.dart';
import 'package:file_manager_view/core/io/extension/extension.dart';
import 'package:file_manager_view/core/io/impl/directory_browser.dart';
import 'package:file_manager_view/core/io/interface/io.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:file_manager_view/v2/ext_util.dart';
import 'package:file_manager_view/v2/file_util.dart';
import 'package:file_manager_view/v2/menu.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:file_manager_view/widgets/file_manager_list_view.dart';
import 'package:file_manager_view/widgets/file_manager_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import 'preview_image.dart';
import 'video.dart';

class FileManager extends StatefulWidget {
  const FileManager({
    Key key,
    this.drawer = true,
    this.path = '/sdcard',
    this.padding,
    this.address,
    this.usePackage = false,
  }) : super(key: key);

  final bool drawer;
  final String path;
  final EdgeInsetsGeometry padding;
  final String address;
  final bool usePackage;

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  FileSelectController fileSelectController = Get.put(FileSelectController());
  FileManagerController fileManagerController;
  bool isGrid = false;

  @override
  void initState() {
    super.initState();
    if (widget.usePackage) {
      Config.flutterPackage = 'packages/file_manager_view/';
    }
    fileManagerController = Get.put(
      FileManagerController(widget.path),
    );
    if (widget.address != null) {
      fileManagerController.changeAddr(widget.address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? OverlayStyle.light
          : OverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xfff3f4f9),
        body: SafeArea(
          left: false,
          child: Padding(
            padding: widget.padding ?? EdgeInsets.all(8.w),
            child: Column(
              children: [
                Padding(
                  padding: (widget.drawer && !GetPlatform.isAndroid)
                      ? EdgeInsets.only(left: 8.w)
                      : EdgeInsets.zero,
                  child: header(),
                ),
                SizedBox(height: 4.w),
                Expanded(
                  child: Row(
                    children: [
                      if (widget.drawer && !GetPlatform.isAndroid)
                        SizedBox(
                          width: 240.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DrawerItem(
                                title: '根目录',
                                icon: Image.asset(
                                  '${Config.flutterPackage}assets/icon/home_sel.png',
                                  width: 20.w,
                                ),
                                groupValue: fileManagerController.dirPath,
                                value: '/sdcard',
                                onTap: (_) {
                                  fileManagerController.updateFileNodes(_);
                                  setState(() {});
                                },
                              ),
                              DrawerItem(
                                title: '文档',
                                icon: SvgPicture.asset(
                                  '${Config.flutterPackage}assets/icon/document.svg',
                                  width: 20.w,
                                ),
                                groupValue: fileManagerController.dirPath,
                                value: '/sdcard/Documents',
                                onTap: (_) {
                                  fileManagerController.updateFileNodes(_);
                                  setState(() {});
                                },
                              ),
                              DrawerItem(
                                title: '下载',
                                icon: SvgPicture.asset(
                                  '${Config.flutterPackage}assets/icon/download.svg',
                                  width: 20.w,
                                ),
                                groupValue: fileManagerController.dirPath,
                                value: '/sdcard/Download',
                                onTap: (_) {
                                  fileManagerController.updateFileNodes(_);
                                  setState(() {});
                                },
                              ),
                              DrawerItem(
                                title: '回收站',
                                icon: SvgPicture.asset(
                                  '${Config.flutterPackage}assets/icon/recycle.svg',
                                  width: 20.w,
                                ),
                                groupValue: fileManagerController.dirPath,
                                value: '2',
                                onTap: (_) {},
                              ),
                              SizedBox(height: 12.w),
                              // Padding(
                              //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                              //   child: const Text(
                              //     '设备',
                              //     style: TextStyle(
                              //       color: Colors.black,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(height: 12.w),
                              // DrawerItem(
                              //   title: '外置储存',
                              //   icon: SvgPicture.asset(
                              //     'assets/icon/document.svg',
                              //     width: 20.w,
                              //   ),
                              //   value: '2',
                              //   onTap: (_) {},
                              // ),
                              // DrawerItem(
                              //   title: '系统',
                              //   icon: SvgPicture.asset(
                              //     'assets/icon/document.svg',
                              //     width: 20.w,
                              //   ),
                              //   value: '2',
                              //   onTap: (_) {},
                              // ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: Material(
                          borderRadius: BorderRadius.circular(12.w),
                          color: Colors.white,
                          clipBehavior: Clip.hardEdge,
                          child: WillPopScope(
                            onWillPop: () async {
                              if (fileManagerController.dirPath == '/') {
                                Get.back();
                              }
                              fileManagerController.updateFileNodes(
                                p.dirname(fileManagerController.dirPath),
                              );
                              return false;
                            },
                            child: FileManagerListView(
                              key: Key(fileManagerController.dirPath),
                              displayType: isGrid
                                  ? WindowDisplayType.grid
                                  : WindowDisplayType.list,
                              itemOnTap: (entity) async {
                                if (entity is File) {
                                  String path = entity.path;
                                  Directory dir = fileManagerController.dir;
                                  if (dir is DirectoryBrowser &&
                                      dir.addr != null) {
                                    Uri uri = Uri.tryParse(dir.addr);
                                    path = 'http://${uri.host}:${uri.port}$path'
                                        .replaceAll('/sdcard', '');
                                  }
                                  FileUtil.openFile(path);
                                  return;
                                }
                                if (entity.name == '..') {
                                  fileManagerController.updateFileNodes(
                                    p.dirname(fileManagerController.dirPath),
                                  );
                                } else {
                                  fileManagerController
                                      .updateFileNodes(entity.path);
                                }
                              },
                              itemOnLongPress: (entity, offset) {
                                Get.dialog(
                                  Menu(
                                    offset: offset,
                                    entity: entity,
                                  ),
                                  barrierColor: Colors.transparent,
                                );
                              },
                              onRightMouseClick: (file, offset) {
                                Get.dialog(
                                  Menu(
                                    offset: offset,
                                    entity: file,
                                  ),
                                  barrierColor: Colors.transparent,
                                );
                              },
                              controller: fileManagerController,
                              windowType: WindowType.defaultType,
                            ),
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
      ),
    );
  }

  SizedBox header() {
    ScrollController scrollController = ScrollController();
    return SizedBox(
      height: 48.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
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
                    child: GetBuilder<FileManagerController>(
                      builder: (controller) {
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (scrollController.hasListeners) {
                            scrollController.jumpTo(
                              scrollController.position.maxScrollExtent,
                            );
                          }
                        });
                        if (controller.dirPath == '/') {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.w,
                              horizontal: 6.w,
                            ),
                            child: Text(
                              '/',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        List<String> dir = controller.dirPath.split('/');
                        Log.w(dir);
                        dir[0] = '/';
                        List<Widget> children = [];
                        for (int i = 0; i < dir.length; i++) {
                          Log.i(i.toString() + dir.take(i + 1).join('/'));
                          if (i == dir.length - 1) {
                            children.add(
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8.w),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.w,
                                  horizontal: 6.w,
                                ),
                                child: Text(
                                  dir[i],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                            break;
                          }
                          children.add(
                            GestureDetector(
                              onTap: () {
                                FileManagerController controller = Get.find();
                                controller.updateFileNodes(dir
                                    .take(i + 1)
                                    .join('/')
                                    .replaceAll('//', '/'));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.w,
                                  horizontal: 6.w,
                                ),
                                child: Text(
                                  dir[i],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(children: children),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.w),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(),
                child: InkWell(
                  onTap: () {
                    isGrid = !isGrid;
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(12.w),
                  child: Icon(isGrid ? Icons.more_vert : Icons.apps),
                ),
              ),
            ),
          ],
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
    this.icon,
  }) : super(key: key);
  final String title;
  final void Function(String value) onTap;
  final String value;
  final String groupValue;
  final Widget icon;
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
                      icon,
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
