import 'package:file_manager_view/file_manager_view.dart';
import 'package:get/get.dart';

class FileSelectController extends GetxController {
  String get currentDir => _currentDir;
  String _currentDir = '';

  void updateCurrentDirPath(String path) {
    _currentDir = path;
  }

  /// 用来存放当前被选择的文件
  List<FileEntity> checkNodes = <FileEntity>[];
  void addCheck(FileEntity fileNode) {
    // print('$this addCheck');
    if (!checkNodes.contains(fileNode)) {
      checkNodes.add(fileNode);
    }
    // print(checkNodes);
  }

  void removeCheck(FileEntity fileNode) {
    checkNodes.remove(fileNode);
  }

  void clearCheck() {
    checkNodes.clear();
    update();
  }
}
