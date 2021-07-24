import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/extension/file_entity_extension.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:file_manager_view/global/controller/clipboard_controller.dart';
import 'package:file_manager_view/global/instance/global.dart';
import 'package:file_manager_view/widgets/file_manager_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as path;
import 'file_manager_controller.dart';

Directory appDocDir;
enum WindowType {
  /// 选择文件
  selectFile,

  /// 选择文件夹
  selectDirectory,

  /// 默认浏览方式
  defaultType,
}
typedef PathCallback = Future<void> Function(String path);

class FileManagerWindow extends StatefulWidget {
  const FileManagerWindow({
    Key key,
    @required this.initPath,
    // 这个值为真，单机item的时候会直接返回item的路径
    this.windowType = WindowType.defaultType,
  }) : super(key: key);
  final String initPath;
  final WindowType windowType;

  @override
  _FileManagerWindowState createState() => _FileManagerWindowState();
}

class _FileManagerWindowState extends State<FileManagerWindow>
    with TickerProviderStateMixin {
  List<FileManagerController> _controllers = [];
  //列表滑动控制器
  final ScrollController _scrollController = ScrollController();
  //动画控制器，用来控制文件夹进入时的透明度
  AnimationController _animationController;
  //透明度动画补间值
  Animation<double> _opacityTween;
  //记录每一次的浏览位置，key 是路径，value是offset
  PageController pageController = PageController(initialPage: 0);
  FileSelectController fileSelectController = Get.find();

  @override
  void initState() {
    super.initState();
    _controllers.add(FileManagerController(widget.initPath));
    fileSelectController?.updateCurrentDirPath(widget.initPath);
    initAnimation();
    pageController.addListener(() {
      setState(() {});
      // Log.d(pageController.page);
      // Log.e(pageController.offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: buldHome(context),
    );
  }

  void initAnimation() {
    //初始化动画，这是切换文件路径时的透明度动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    final Animation<double> curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.ease,
    );
    _opacityTween = Tween<double>(begin: 0.0, end: 1.0)
        .animate(curve); //初始化这个动画的值始终为一，那么第一次打开就不会有透明度的变化
    _opacityTween.addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  void repeatAnima() {
    //重复播放动画
    _animationController.reset();
    _animationController.forward();
  }
  // 这是一个异步方法，来获得文件节点的其他参数

  Future<bool> onWillPop() async {
    if (_controllers.length == 1) {
      SystemNavigator.pop();
    } else {
      await pageController.previousPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
      _controllers.removeLast();
      setState(() {});
    }

    // final Clipboards clipboards = Global.instance.clipboards;
    // clipboards.clearCheck();
    // if (Scaffold.of(context).isDrawerOpen) {
    //   return true;
    // }
    // // if (widget.windowType==WindowType.) {
    // //   //当在其他面直接唤起文件管理器的时候返回键直接pop
    // //   return true;
    // // }
    // if (_controller.dirPath == '/') {
    //   Navigator.pop(context);
    // }
    // final String backpath = path.dirname(_controller.dirPath);
    // _controller.updateFileNodes(backpath);

    // return false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();

    super.dispose();
  }

  WillPopScope buldHome(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Material(
        color: const Color(0xfff5f5f7),
        elevation: 0.0,
        child: FadeTransition(
          opacity: _opacityTween,
          child: PageView.builder(
            controller: pageController,
            itemCount: _controllers.length,
            itemBuilder: (c, index) {
              double scale = 1.0;
              if (pageController.hasClients && _controllers.length > 1) {
                // int currentPage
                // pageController.
                if (pageController.page.toInt() - index == 0) {
                  // Log.d('index -> $index');
                  scale = 1 - 0.4 * (pageController.page - index);
                } else {
                  // Log.w(
                  //     'index - pageController.page -> ${index - pageController.page}');
                  scale = 0.6 + 0.4 * (pageController.page - index + 1);
                }
              }
              return Transform(
                transform: Matrix4.identity()..scale(scale),
                child: FileManagerListView(
                  itemOnTap: (entity) async {
                    FileManagerController ctl =
                        FileManagerController(entity.path);
                    if (entity.isDirectory) {
                      if (entity.name == '..') {
                        await pageController.previousPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                        );
                        _controllers.removeLast();
                        fileSelectController
                            ?.updateCurrentDirPath(entity.parentPath);
                      } else {
                        _controllers.add(ctl);
                        pageController.nextPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                        );
                        fileSelectController?.updateCurrentDirPath(entity.path);
                        setState(() {});
                      }
                    }
                  },
                  itemOnLongPress: (entity) {},
                  controller: _controllers[index],
                  windowType: widget.windowType,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
