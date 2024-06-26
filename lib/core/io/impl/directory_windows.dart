import 'dart:io' as io;

import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:file_manager_view/core/io/interface/file.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:file_manager_view/core/io/util/directory_factory.dart';
import 'package:global_repository/global_repository.dart';

class DirectoryWindows extends FileEntity implements Directory {
  DirectoryWindows(String path, {String ?info, Executable ?shell}) {
    this.path = path;
    this.info = info;
  }
  @override
  Future<List<FileEntity>> list({
    bool verbose = false,
  }) async {
    final List<FileEntity> _fileNodes = <FileEntity>[];
    _fileNodes.add(DirectoryFactory.getPlatformDirectory(
      path + io.Platform.pathSeparator + '..',
    ));
    for (final io.FileSystemEntity fileSystemEntity
        in io.Directory(path).listSync()) {
      if (fileSystemEntity is Directory) {
        _fileNodes.add(DirectoryFactory.getPlatformDirectory(fileSystemEntity.path));
      } else {
        _fileNodes.add(File.getPlatformFile(fileSystemEntity.path, ''));
      }
    }
    return _fileNodes;
  }
}
