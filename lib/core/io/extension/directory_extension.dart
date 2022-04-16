import 'package:file_manager_view/core/io/extension/extension.dart';
import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';

extension DirExt on Directory {
  Future<List<FileEntity>> listSort() async {
    List<FileEntity> tmp = await list();
    tmp.sort((FileEntity a, FileEntity b) => a.compareTo(b));
    return tmp;
  }
}
