import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:global_repository/global_repository.dart';

import 'directory_unix.dart';

class DirectoryBrowser extends FileEntity implements Directory {
  DirectoryBrowser(String path, {String info = '', Executable ?shell}) {
    this.path = path;
    this.info = info;
  }

  late String addr;

  @override
  Future<List<FileEntity>> list({
    bool verbose = true,
  }) async {
    late Response<String> response;
    try {
      response = await Dio().get<String>(
        '$addr/getdir',
        queryParameters: {'path': path},
      );
    } catch (e) {
      Log.e('$this error ->$e');
    }
    List<dynamic> full = (jsonDecode(response.data!) as List<dynamic>);
    List<String> ful = full.cast();
    return getFilesFrom(ful, path);
  }
}
