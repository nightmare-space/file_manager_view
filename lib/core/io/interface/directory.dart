import 'dart:io';

import 'package:file_manager_view/core/io/impl/directory_browser.dart';
import 'package:file_manager_view/core/io/impl/directory_unix.dart';
import 'package:file_manager_view/core/io/impl/directory_windows.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'file_entity.dart';

abstract class Directory extends FileEntity {
 
  Future<List<FileEntity>> list();

  @override
  String toString() {
    return 'path : $path';
  }
}
