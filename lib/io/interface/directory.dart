import 'dart:io';

import 'package:file_manager_view/io/impl/directory_browser.dart';
import 'package:file_manager_view/io/impl/directory_unix.dart';
import 'package:file_manager_view/io/impl/directory_windows.dart';
import 'package:global_repository/global_repository.dart';

import 'file_entity.dart';

abstract class Directory extends FileEntity {
  factory Directory.getPlatformDirectory(
    String path, {
    String info = '',
    Executable shell,
  }) {
    shell ??= YanProcess();
    if (Platform.isWindows) {
      return DirectoryWindows(path, info: info, shell: shell);
    } else if (Platform.isMacOS) {
      return DirectoryBrowser(path, info: info, shell: shell);
    } else if (Platform.isAndroid) {
      return DirectoryUnix(path, info: info, shell: shell);
    }
    throw '没有平台对应的实现';
  }

  // 默认实现

  //
  Future<List<FileEntity>> list();

  @override
  String toString() {
    return 'path : $path';
  }
}
