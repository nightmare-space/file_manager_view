import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/core/io/extension/extension.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:file_manager_view/v2/icon.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:keframe/size_cache_widget.dart';

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
    Key key,
    @required this.controller,
    this.windowType,
    this.itemOnTap,
    this.itemOnLongPress,
    this.initScrollOffset = 0,
    this.onRightMouseClick,
    this.displayType = WindowDisplayType.list,
  }) : super(key: key);

  final FileManagerController controller;
  final WindowType windowType;
  final FileOnTap itemOnTap;
  final FileOnLongPress itemOnLongPress;
  final double initScrollOffset;
  final OnRightMouseClick onRightMouseClick;
  final WindowDisplayType displayType;

  @override
  _FileManagerListViewState createState() => _FileManagerListViewState();
}

class _FileManagerListViewState extends State<FileManagerListView> {
  Future<void> initFMPage() async {
    //页面启动的时候的初始化
    widget.controller.addListener(controllerCallback);
    Log.d('初始化的路径 -> ${widget.controller.dirPath}');
    if (widget.controller.fileNodes.isEmpty) {
      widget.controller.updateFileNodes();
    }
  }

  void controllerCallback() {
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
        final List<String> infos = fileNode.info.split(RegExp(r'\s{1,}'));
        // Log.w(infos);
        fileNode.modified = '${infos[3]}  ${infos[4]}';
        if (fileNode.isFile) {
          fileNode.size = FileSizeUtils.getFileSizeFromStr(infos[2]);
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

  Offset offset;

  void handleOnTap() {}
  @override
  Widget build(BuildContext context) {
    if (widget.controller.fileNodes.isEmpty) {
      return const SizedBox();
    }
    if (widget.displayType == WindowDisplayType.grid) {
      return LayoutBuilder(builder: (context, con) {
        return SizeCacheWidget(
          child: GridView.builder(
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
              return FrameSeparateWidget(
                index: index,
                placeHolder: Container(
                  height: 54.w,
                ),
                child: GridFileItem(
                  entity: entity,
                  onTap: () {
                    widget.itemOnTap?.call(entity);
                  },
                ),
              );
            },
          ),
        );
      });
    }
    return RefreshIndicator(
      onRefresh: () async {
        widget.controller.updateFileNodes();
      },
      displacement: 1,
      child: SizeCacheWidget(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 400,
          controller:
              ScrollController(initialScrollOffset: widget.initScrollOffset),
          itemCount: widget.controller.fileNodes.length,
          padding: EdgeInsets.only(bottom: 100.w),
          //不然会有一个距离上面的边距
          itemBuilder: (BuildContext context, int index) {
            final FileEntity entity = widget.controller.fileNodes[index];
            return FrameSeparateWidget(
              index: index,
              placeHolder: Container(
                height: 54.w,
              ),
              child: Builder(builder: (context) {
                return Listener(
                  onPointerDown: (PointerDownEvent event) {
                    if (event.kind == PointerDeviceKind.mouse &&
                        event.buttons == kSecondaryMouseButton) {
                      widget.onRightMouseClick?.call(entity, offset);
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
                          widget.itemOnLongPress?.call(entity, offset);
                        },
                        fileEntity: entity,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class GridFileItem extends StatefulWidget {
  const GridFileItem({
    Key key,
    this.entity,
    this.onTap,
  }) : super(key: key);
  final FileEntity entity;
  final void Function() onTap;

  @override
  State<GridFileItem> createState() => _GridFileItemState();
}

class _GridFileItemState extends State<GridFileItem> {
  @override
  Widget build(BuildContext context) {
    FileEntity fileEntity = widget.entity;
    Widget icon;
    if (fileEntity.isDirectory) {
      icon = SvgPicture.asset(
        '${Config.flutterPackage}assets/icon/dir.svg',
        width: 32.w,
        height: 32.w,
        color: Theme.of(context).primaryColor,
      );
    } else {
      icon = getIconByExt(fileEntity.path);
    }
    return InkWell(
      onTap: () {
        widget.onTap?.call();
      },
      child: LayoutBuilder(builder: (context, con) {
        Log.i('con : $con');
        return SizedBox(
          width: con.maxWidth,
          height: con.maxHeight,
          // color: Colors.red,
          child: Column(
            children: [
              SizedBox(height: 12.w),
              SizedBox(
                width: con.maxWidth - 20.w,
                height: con.maxHeight - 60.w,
                child: icon,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  fileEntity.name,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.w,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class FileItem extends StatefulWidget {
  const FileItem({
    Key key,
    this.fileEntity,
    this.isCheck = false,
    this.checkCall,
    this.apkTool,
    this.controller,
    this.onTap,
    this.onLongPress,
    this.windowType = WindowType.defaultType,
  }) : super(key: key);

  final FileManagerController controller;
  final FileEntity fileEntity;
  final Function apkTool;
  final bool isCheck;
  final Function(String path) checkCall;
  final void Function() onTap;
  final void Function() onLongPress;
  final WindowType windowType;

  @override
  _FileItemState createState() => _FileItemState();
}

class _FileItemState extends State<FileItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController; //动画控制器
  Animation<double> curvedAnimation;
  Animation<double> tweenPadding; //边距动画补间值
  FileEntity fileEntity;

  FileSelectController clipboardController = Get.find();

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  void initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    );
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
  }

  double dx = 0.0;
  void _handleDragStart(DragStartDetails details) {
    //控件点击的回调
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // print(details.globalPosition);
    // if (dx >= 40.0) {
    //   if (dx != (details.globalPosition.dx - _tmp)) {
    //     Feedback.forLongPress(context);
    //   }
    // } else
    dx += details.delta.dx;
    if (dx >= 40) {
      dx = 40.0;
    }
    if (dx <= 0) {
      dx = 0;
    }
    // print(dx);
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (dx == 40.0) {
      Feedback.forLongPress(context);
      clipboardController.addCheck(fileEntity);
      setState(() {});
    }
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
    tweenPadding.addListener(() {
      setState(() {
        dx = tweenPadding.value;
      });
    });
    _animationController.reset();
    _animationController.forward().whenComplete(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fileEntity = widget.fileEntity;
    final List<String> _tmp = fileEntity.path.split(' -> '); //有的有符号链接
    final String currentFileName = _tmp.first.split('/').last; //取前面那个就没错
    // Log.d(fileEntity);

    Widget icon;
    if (fileEntity.isDirectory) {
      icon = SvgPicture.asset(
        '${Config.flutterPackage}assets/icon/dir.svg',
        width: 32.w,
        height: 32.w,
        color: Theme.of(context).primaryColor,
      );
    } else {
      icon = getIconByExt(fileEntity.path);
    }
    return SizedBox(
      height: 54.w,
      child: Stack(
        children: <Widget>[
          if (clipboardController.checkNodes.contains(fileEntity))
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          InkWell(
            splashColor: Colors.transparent,
            onLongPress: () {
              widget.onLongPress();
            },
            onTap: () {
              if (widget.windowType == WindowType.selectFile &&
                  widget.fileEntity.isFile) {
                Feedback.forLongPress(context);
                if (clipboardController.checkNodes.contains(fileEntity)) {
                  clipboardController.removeCheck(widget.fileEntity);
                  setState(() {});
                } else {
                  clipboardController.addCheck(widget.fileEntity);
                  setState(() {});
                }
              }
              widget.onTap();
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: Transform(
                transform: Matrix4.identity()..translate(dx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // header icon
                          SizedBox(
                            width: 30.w,
                            height: 30.w,
                            child: icon,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  // width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      currentFileName,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width -
                                        8 -
                                        30,
                                    child: Text(
                                      '${fileEntity.modified} ${fileEntity.itemsNumber} ${fileEntity.mode} ${fileEntity.size}',
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      FileItemSuffix(
                        fileNode: fileEntity,
                      ),
                      if (_tmp.length == 2)
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '->    ',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
