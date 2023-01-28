// import 'dart:io' as io;


import 'package:file_manager_view/core/io/interface/file.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';

class FileUnix extends FileEntity implements File {
  FileUnix(String path, {String ?info}) {
    this.path = path;
    this.info = info;
  }
  @override
  Future<bool> rename(String name) async {
    await shell?.exec('mv $path $parentPath/$name');
    return true;
  }
}
