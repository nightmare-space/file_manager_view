import 'package:dio/dio.dart';
import 'package:file_manager_view/io/interface/directory.dart';
import 'package:file_manager_view/io/interface/file_entity.dart';
import 'package:global_repository/global_repository.dart';

class DirectoryBrowser extends FileEntity implements Directory {
  DirectoryBrowser(String path, {String info = '', Executable shell}) {
    this.path = path;
    this.info = info;
  }

  @override
  Future<List<FileEntity>> list({
    bool verbose = true,
  }) async {
    return [];
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
      'http://192.168.244.137:8000',
      options: Options(
        method: 'POST',
        headers: <String, dynamic>{
          'cmdline': cmdline,
        },
      ),
    );
    return response.data;
  } catch (e) {
    print('error ->$e');
    return '';
  }
  // print('result -> $result');
}
