import 'package:file_manager_view/core/io/extension/extension.dart';
import 'package:file_manager_view/core/io/impl/directory_browser.dart';
import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:file_manager_view/core/io/util/directory_factory.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:global_repository/global_repository.dart';

class FileManagerController extends GetxController {
  FileManagerController(
    this.dirPath, {
    this.initOffset = 0,
  }) {
    Log.e('初始化');
  }
  final double initOffset;
  String dirPath;
  Directory dir;
  //保存所有文件的节点
  List<FileEntity> fileNodes = <FileEntity>[];
  String addr;
  void changeAddr(String addr) {
    this.addr = addr;
  }

  Future<void> updateFileNodes([String path]) async {
    dirPath = path ?? dirPath;
    // 获取文件列表和刷新页面
    dir = DirectoryFactory.getPlatformDirectory(
      dirPath,
    );
    if (dir is DirectoryBrowser) {
      (dir as DirectoryBrowser).addr = addr;
    }
    fileNodes = await dir.listSort();
    update();
    // 在一次获取后异步更新文件节点的其他参数，这个过程是非常快的
    // getNodeFullArgs();
  }

  void updatePath(String path) {
    dirPath = path;
    update();
  }
}
