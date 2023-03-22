import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/core/io/interface/io.dart';
import 'package:file_manager_view/v2/icon.dart';
import 'package:file_manager_view/widgets/file_item_suffix.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:file_manager_view/widgets/file_manager_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class FileItem extends StatefulWidget {
  const FileItem({
    Key? key,
    required this.fileEntity,
    this.isCheck = false,
    this.checkCall,
    this.apkTool,
    required this.controller,
    required this.onTap,
    required this.onLongPress,
    this.windowType = WindowType.defaultType,
  }) : super(key: key);

  final FileManagerController controller;
  final FileEntity fileEntity;
  final Function? apkTool;
  final bool isCheck;
  final Function(String path)? checkCall;
  final void Function() onTap;
  final void Function() onLongPress;
  final WindowType windowType;

  @override
  State createState() => _FileItemState();
}

class _FileItemState extends State<FileItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController; //动画控制器
  late Animation<double> curvedAnimation;
  late Animation<double> tweenPadding; //边距动画补间值
  late FileEntity fileEntity;

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
              if (widget.windowType == WindowType.selectFile && widget.fileEntity.isFile) {
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
                                    width: MediaQuery.of(context).size.width - 8 - 30,
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
