import 'package:file_manager_view/extension/directory_extension.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:flutter/material.dart';

import 'observable.dart';

class FileManagerController with Observable {
  FileManagerController(this.dirPath);

  String dirPath;

  //保存所有文件的节点
  List<FileEntity> fileNodes = <FileEntity>[];

  Future<void> updateFileNodes([String path]) async {
    dirPath = path ?? dirPath;
    print('_getFileNodes $dirPath');
    // 获取文件列表和刷新页面
    final Directory dir = Directory.getPlatformDirectory(
      dirPath,
    );
    fileNodes = await dir.listSort();
    print('_getFileNodes后');
    notifyListeners();
    // 在一次获取后异步更新文件节点的其他参数，这个过程是非常快的
    // getNodeFullArgs();
  }

  void setStatePathFile() {
    /// 在新建页面删除页面的时候会用到
    /// 页面初始打开会读取这个文件生成页面
    // if (Platform.isAndroid) {
    //   File('${Config.filesPath}/FileManager/History_Path').writeAsString(
    //     _dirPaths.join('\n'),
    //   );
    // }
  }
  void updatePath(String path) {
    dirPath = path;
    notifyListeners();
  }
}
