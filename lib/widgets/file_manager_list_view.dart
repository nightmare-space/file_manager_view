import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/core/io/extension/extension.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:file_manager_view/v2/icon.dart';
import 'package:file_manager_view/views/file_item.dart';
import 'package:file_manager_view/views/grid_file_item.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'file_item_suffix.dart';
import 'file_manager_window.dart';

typedef FileOnTap = void Function(FileEntity fileEntity);
typedef FileOnLongPress = void Function(FileEntity fileEntity, Offset offset);
typedef OnRightMouseClick = void Function(FileEntity fileEntity, Offset offset);

enum WindowDisplayType {
  list,
  grid,
}

class FileManagerListView extends StatefulWidget {
  const FileManagerListView({
    Key? key,
    required this.controller,
    required this.windowType,
    this.itemOnTap,
    this.itemOnLongPress,
    this.initScrollOffset = 0,
    this.onRightMouseClick,
    this.displayType = WindowDisplayType.list,
  }) : super(key: key);

  final FileManagerController controller;
  final WindowType windowType;
  final FileOnTap? itemOnTap;
  final FileOnLongPress? itemOnLongPress;
  final double initScrollOffset;
  final OnRightMouseClick? onRightMouseClick;
  final WindowDisplayType displayType;

  @override
  State createState() => _FileManagerListViewState();
}

class _FileManagerListViewState extends State<FileManagerListView> {
  Future<void> initFMPage() async {
    //页面启动的时候的初始化
    widget.controller.addListener(controllerCallback);
    Log.d('初始化的路径 -> ${widget.controller.dirPath}');
    widget.controller.updateFileNodes();
  }

  void controllerCallback() {
    setState(() {});
    if (mounted) {
      getNodeFullArgs();
      // if (historyOffset.keys.contains(_controller.dirPath)) {
      //   _scrollController.jumpTo(historyOffset[_controller.dirPath]);
      //   historyOffset.remove(_controller.dirPath);
      // } else {
      //   _scrollController.jumpTo(0);
      // }
    }
  }

  Future<void> getNodeFullArgs() async {
    for (final FileEntity fileNode in widget.controller.fileNodes) {
      //将文件的ls输出详情以空格隔开分成列表
      if (fileNode.name != '..') {
        final List<String> infos = fileNode.info!.split(RegExp(r'\s{1,}'));
        // Log.w(infos);
        fileNode.modified = '${infos[3]}  ${infos[4]}';
        if (fileNode.isFile) {
          fileNode.size = FileSizeUtils.getFileSizeFromStr(infos[2])!;
        } else {
          fileNode.itemsNumber = '${infos[1]}项';
        }
        fileNode.mode = infos[0];
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(widget.controller);
    initFMPage();
  }

  @override
  void dispose() {
    widget.controller.removeListener(controllerCallback);
    super.dispose();
  }

  int getCount(double max) {
    Log.i((414.w - 20.w) / 84.w);
    return (max - 20.w) ~/ 78.w;
  }

  Offset? offset;

  void handleOnTap() {}
  @override
  Widget build(BuildContext context) {
    if (widget.controller.fileNodes.isEmpty) {
      return const SizedBox();
    }
    if (widget.displayType == WindowDisplayType.grid) {
      return LayoutBuilder(builder: (context, con) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getCount(con.maxWidth),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: 0.8,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: widget.controller.fileNodes.length,
          padding: EdgeInsets.only(top: 10.w),
          itemBuilder: (BuildContext context, int index) {
            final FileEntity entity = widget.controller.fileNodes[index];
            return GridFileItem(
              windowType: widget.windowType,
              entity: entity,
              onTap: () {
                widget.itemOnTap?.call(entity);
              },
            );
          },
        );
      });
    }
    return RefreshIndicator(
      onRefresh: () async {
        widget.controller.updateFileNodes();
      },
      displacement: 1,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        cacheExtent: 400,
        controller: ScrollController(initialScrollOffset: widget.initScrollOffset),
        itemCount: widget.controller.fileNodes.length,
        padding: EdgeInsets.only(bottom: 100.w),
        //不然会有一个距离上面的边距
        itemBuilder: (BuildContext context, int index) {
          final FileEntity entity = widget.controller.fileNodes[index];
          return Builder(builder: (context) {
            return Listener(
              onPointerDown: (PointerDownEvent event) {
                if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
                  widget.onRightMouseClick?.call(entity, offset!);
                }
              },
              child: GestureDetector(
                onPanDown: (details) {
                  offset = details.globalPosition;
                },
                child: MouseRegion(
                  onHover: (event) {
                    offset = event.position;
                  },
                  child: FileItem(
                    key: Key(entity.path),
                    windowType: widget.windowType,
                    controller: widget.controller,
                    onTap: () {
                      widget.itemOnTap?.call(entity);
                    },
                    onLongPress: () {
                      widget.itemOnLongPress?.call(entity, offset!);
                    },
                    fileEntity: entity,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
