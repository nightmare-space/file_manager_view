import 'package:file_manager_view/core/io/impl/file_unix.dart';

import 'file_entity.dart';

abstract class File extends FileEntity {
  factory File.getPlatformFile(String path, String info) {
    // TODO: 根据平台返回
    return FileUnix(path, info: info);
  }

  late String _path;
  @override
  String get path => _path;
}
