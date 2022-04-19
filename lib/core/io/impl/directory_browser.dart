import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:file_manager_view/main.dart';
import 'package:global_repository/global_repository.dart';

import 'directory_unix.dart';

class DirectoryBrowser extends FileEntity implements Directory {
  DirectoryBrowser(String path, {String info = '', Executable shell}) {
    this.path = path;
    this.info = info;
  }
  @override
  Future<List<FileEntity>> list({
    bool verbose = true,
  }) async {
    Response<String> response;

    try {
      response = await Dio().get<String>(
        '$urlPrefix/getdir',
        queryParameters: {
          'path': path,
        },
      );
      // Log.e(response.data);
      // return response.data;
    } catch (e) {
      Log.e('$this error ->$e');
      // return '';
    }
    List<dynamic> full = (jsonDecode(response.data) as List<dynamic>);
    List<String> ful = full.cast();
    // for (var data in full) {
    //   ful.add(data.toString());
    // }
    // ful.addAll(full.cast());
    return getFilesFrom(ful, path);
  }
}
