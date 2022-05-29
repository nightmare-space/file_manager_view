import 'dart:io' as io;
import 'dart:io';
import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:file_manager_view/core/io/interface/file.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:file_manager_view/core/io/util/directory_factory.dart';
import 'package:global_repository/global_repository.dart';

class DirectoryUnix extends FileEntity implements Directory {
  DirectoryUnix(String path, {String info, Executable shell}) {
    this.path = path;
    this.info = info;
    this.shell = shell;
  }

  @override
  Future<List<FileEntity>> list() async {
    List<String> fullmessage = await getFullMessage(path);
    Log.i(fullmessage);
    return getFilesFrom(fullmessage.cast<String>(), path);
  }
}

Future<List<String>> getFullMessage(String path) async {
  // --------------------------------------
  String lsPath = 'ls';
  if (io.Platform.isAndroid) {
    lsPath = '/system/bin/ls';
  }
  // --------------------------------------
  List<String> fullmessage = <String>[];

  path = path.replaceAll('//', '/');
  // 获得ls命令的输出
  final String lsOut = await exec(
    '$lsPath -aog "$path"\n',
  );
  lsOut.split('\n').forEach((element) {
    // Log.d(element);
  });
  // 删除第一行 -> total xxx
  fullmessage = lsOut.split('\n')..removeAt(0);
  // ------------------------------------------------------------------------
  // ------------------------- 不要动这段代码，阿弥陀佛。-------------------------
  // linkFileNode 是当前文件节点有符号链接的情况。
  String linkFileNode = '';
  for (int i = 0; i < fullmessage.length; i++) {
    if (fullmessage[i].startsWith('l')) {
      //说明这个节点是符号链接
      if (fullmessage[i].split(' -> ').last.startsWith('/')) {
        //首先以 -> 符号分割开，last拿到的是该节点链接到的那个元素
        //如果这个元素不是以/开始，则该符号链接使用的是相对链接
        linkFileNode += fullmessage[i].split(' -> ').last + '\n';
      } else {
        linkFileNode += '$path/${fullmessage[i].split(' -> ').last}\n';
      }
    }
  }
  linkFileNode.split('\n').forEach((element) {});

  //
  if (linkFileNode.isNotEmpty) {
    // 当当前文件夹存在包含符号链接的节点时
    //-g取消打印owner  -0取消打印group   -L不跟随符号链接，会指向整个符号链接最后指向的那个
    final String lsOut = await exec(
      'echo "$linkFileNode"|xargs $lsPath -ALdog\n',
    );
    final List<String> linkFileNodes = lsOut.replaceAll('//', '/').split('\n');

    Log.i('====>$linkFileNodes');

    // 文件名到文件类型的 map
    // 例如 tmp:d
    // 类型是tag，'d'->文件夹，'l'->符号链接，'-'->普通文件
    final Map<String, String> map = <String, String>{};
    for (final String str in linkFileNodes) {
      // print(str);
      final String key = str.replaceAll(RegExp('^.*[0-9] /'), '/');
      Log.i('key->$key');
      map[key] = str.substring(0, 1);
    }
    Log.i('====>$map');

    for (int i = 0; i < fullmessage.length; i++) {
      final String linkFromFile = fullmessage[i].split(' -> ').last;

      Log.i('linkFromFile====>$linkFromFile');

      Log.i('map.keys->${map.keys}');
      Log.i('map.keys->${map.keys.contains(linkFromFile)}');
      if (map.keys.contains(linkFromFile)) {
        fullmessage[i] = fullmessage[i]
            .replaceAll(RegExp('^l'), map[fullmessage[i].split(' -> ').last]);
        // f.remove(f.first);r
      }
    }
  }
  return fullmessage;
  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
}

List<FileEntity> getFilesFrom(List<String> data, String path) {
  int startIndex;
  final List<FileEntity> fileNodes = <FileEntity>[];
  data.removeWhere((String element) {
    //查找 -> ' .' 这个所在的行数
    return element.endsWith(' .');
  });
  final int currentIndex = data.indexWhere((String element) {
    //查找 -> ' ..' 这个所在的行数
    return element.endsWith(' ..');
  });
  if (currentIndex == -1) {
    fileNodes.add(DirectoryFactory.getPlatformDirectory('..'));
  }
  // Log.i('currentIndex-->$currentIndex');

  // ls 命令输出有空格上的对齐，不能用 list.split 然后以多个空格分开的方式来解析数据
  // 因为有的文件(夹)存在空格
  if (data.isNotEmpty) {
    if (currentIndex == -1) {
      startIndex = data.first.indexOf(
        RegExp(':[0-9][0-9] '),
      ); //获取文件名开始的地址
      startIndex += 4;
    } else {
      startIndex = data[currentIndex].indexOf(
            ' ..',
          ) +
          1;
    }
    Log.i(startIndex);
    if (path == '/') {
      //如果当前路径已经是/就不需要再加一个/了
      for (int i = 0; i < data.length; i++) {
        FileEntity fileEntity;
        if (data[i].startsWith(RegExp('-|l'))) {
          fileEntity = File.getPlatformFile(
            path + data[i].substring(startIndex),
            data[i],
          );
        } else {
          fileEntity = DirectoryFactory.getPlatformDirectory(
            path + data[i].substring(startIndex),
            info: data[i],
          );
        }
        fileNodes.add(fileEntity);
      }
    } else {
      for (int i = 0; i < data.length; i++) {
        FileEntity fileEntity;
        if (data[i].startsWith(RegExp('-|l'))) {
          fileEntity = File.getPlatformFile(
            '$path/' + data[i].substring(startIndex),
            data[i],
          );
        } else {
          fileEntity = DirectoryFactory.getPlatformDirectory(
            '$path/' + data[i].substring(startIndex),
            info: data[i],
          );
        }
        fileNodes.add(fileEntity);
      }
    }
  }
  return fileNodes;
}

Future<String> exec(String cmd) async {
  String value = '';
  final ProcessResult result = await Process.run(
    'sh',
    ['-c', cmd],
    environment: io.Platform.environment,
  );
  value += result.stdout.toString();
  value += result.stderr.toString();
  return value.trim();
}