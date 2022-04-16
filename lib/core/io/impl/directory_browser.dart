import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_manager_view/core/io/document/document.dart';
import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:flutter/foundation.dart';
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
    Uri uri = Uri.tryParse(url);
    String perfix = 'http://${uri.host}:20000';
    if (kIsWeb && kDebugMode) {
      perfix = 'http://192.168.247.102:20000';
    }
    try {
      response = await Dio().get<String>(
        '$perfix/getdir',
        queryParameters: {
          'path': path,
        },
      );
      Log.e(response.data);

      // return response.data;
    } catch (e) {
      print('error ->$e');
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

Future<String> getResultFromServer(String cmdline) async {
  // httpInstance.options.headers['cmdline'] = cmdline;
  // httpInstance.options.contentType = Headers.contentTypeHeader;
  // print(httpInstance.options.headers);
  // final Response<String> result = await httpInstance.get<String>(
  //   'http://127.0.0.1:8001',
  // );
  try {
    final Response<String> response = await Dio().get<String>(
      'http://127.0.0.1:8000/getdir',
    );
    return response.data;
  } catch (e) {
    print('error ->$e');
    return '';
  }
  // print('result -> $result');
}
