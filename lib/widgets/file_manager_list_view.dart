import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/extension/file_entity_extension.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'file_item_suffix.dart';
import 'file_manager_window.dart';
import 'gesture_handler.dart';
import 'item_head.dart';

typedef FileOnTap = void Function(FileEntity fileEntity);
typedef FileOnLongPress = void Function(FileEntity fileEntity);

class FileManagerListView extends StatefulWidget {
  const FileManagerListView({
    Key key,
    @required this.controller,
    this.windowType,
    this.itemOnTap,
    this.itemOnLongPress,
    this.initScrollOffset = 0,
  }) : super(key: key);
  final FileManagerController controller;
  final WindowType windowType;
  final FileOnTap itemOnTap;
  final FileOnLongPress itemOnLongPress;
  final double initScrollOffset;

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
    initFMPage();
  }

  @override
  void dispose() {
    widget.controller.removeListener(controllerCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.fileNodes.isEmpty) {
      return SizedBox();
    }
    return RefreshIndicator(
      onRefresh: () async {
        widget.controller.updateFileNodes();
      },
      displacement: 1,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 400,
        controller:
            ScrollController(initialScrollOffset: widget.initScrollOffset),
        itemCount: widget.controller.fileNodes.length,
        padding: EdgeInsets.only(bottom: 100),
        //不然会有一个距离上面的边距
        itemBuilder: (BuildContext context, int index) {
          final FileEntity entity = widget.controller.fileNodes[index];
          return FileItem(
            windowType: widget.windowType,
            controller: widget.controller,
            onTap: () {
              // if (widget.windowType == WindowType.selectFile && entity.isFile) {
              //   // Navigator.pop(
              //   //   context,
              //   //   '${_controller.dirPath}/${entity.fileName}',
              //   // );
              //   return;
              // }
              // itemOnTap(
              //   entity: entity,
              //   controller: widget.controller,
              //   scrollController: scrollController,
              //   context: context,
              // );
              widget.itemOnTap?.call(entity);
            },
            onLongPress: () {
              widget.itemOnLongPress?.call(entity);
              // if (widget.windowType != WindowType.defaultType) {
              //   return;
              // }
              // itemOnLongPress(
              //   context: context,
              //   entity: entity,
              //   controller: _controller,
              // );
            },
            fileEntity: entity,
          );
        },
      ),
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
    final Widget _iconData = getWidgetFromExtension(
      fileEntity,
      context,
      fileEntity.isFile,
    ); //显示的头部件
    return Container(
      height: 54,
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
                            width: 30,
                            height: 30,
                            child: _iconData,
                          ),
                          SizedBox(
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
                                      style: TextStyle(
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
                                      style: TextStyle(
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
