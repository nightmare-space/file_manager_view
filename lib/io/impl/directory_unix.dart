import 'dart:io' as io;
import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/extension/file_entity_extension.dart';
import 'package:file_manager_view/io/interface/directory.dart';
import 'package:file_manager_view/io/interface/file.dart';
import 'package:file_manager_view/io/interface/file_entity.dart';
import 'package:global_repository/global_repository.dart';
import 'package:signale/signale.dart';

class DirectoryUnix extends FileEntity implements Directory {
  DirectoryUnix(String path, {String info, XProcess shell}) {
    this.path = path;
    this.info = info;
    this.shell = shell;
  }

  @override
  Future<List<FileEntity>> list() async {
    final List<FileEntity> _fileNodes = <FileEntity>[];

    // --------------------------------------
    String lsPath = 'ls';
    if (io.Platform.isAndroid) {
      lsPath = '/system/bin/ls';
    }
    // --------------------------------------
    int _startIndex;
    List<String> _fullmessage = <String>[];
    path = path.replaceAll('//', '/');
    // print('刷新的路径=====>>${PlatformUtil.getUnixPath(path)}');
    final String lsOut = await shell.exec(
      '$lsPath -aog "$path"\n',
    );
    if (enableLog) {
      lsOut.split('\n').forEach((element) {
        Log.d(element);
      });
    }
    // 删除第一行 -> total xxx
    _fullmessage = lsOut.split('\n')..removeAt(0);
    // ------------------------------------------------------------------------
    // ------------------------- 不要动这段代码，阿弥陀佛。-------------------------
    // linkFileNode 是当前文件节点有符号链接的情况。
    String linkFileNode = '';
    for (int i = 0; i < _fullmessage.length; i++) {
      if (_fullmessage[i].startsWith('l')) {
        //说明这个节点是符号链接
        if (_fullmessage[i].split(' -> ').last.startsWith('/')) {
          //首先以 -> 符号分割开，last拿到的是该节点链接到的那个元素
          //如果这个元素不是以/开始，则该符号链接使用的是相对链接
          linkFileNode += _fullmessage[i].split(' -> ').last + '\n';
        } else {
          linkFileNode += '$path/${_fullmessage[i].split(' -> ').last}\n';
        }
      }
    }
    if (enableLog) {
      // PrintUtil.printn('------------ linkFileNode ------------', 35, 47);
      linkFileNode.split('\n').forEach((element) {
        // PrintUtil.printn(element, 35, 47);
      });
      // PrintUtil.printn('------------ linkFileNode ------------', 35, 47);
    }
    //
    if (linkFileNode.isNotEmpty) {
      // 当当前文件夹存在包含符号链接的节点时
      //-g取消打印owner  -0取消打印group   -L不跟随符号链接，会指向整个符号链接最后指向的那个
      final String lsOut = await shell.exec(
        'echo "$linkFileNode"|xargs $lsPath -ALdog\n',
      );
      final List<String> linkFileNodes =
          lsOut.replaceAll('//', '/').split('\n');

      if (enableLog) {
        print('====>$linkFileNodes');
      }
      // 文件名到文件类型的 map
      // 例如 tmp:d
      // 类型是tag，'d'->文件夹，'l'->符号链接，'-'->普通文件
      final Map<String, String> map = <String, String>{};
      for (final String str in linkFileNodes) {
        // print(str);
        final String key = str.replaceAll(RegExp('^.*[0-9] /'), '/');
        print('key->$key');
        map[key] = str.substring(0, 1);
      }
      if (enableLog) {
        print('====>$map');
      }
      for (int i = 0; i < _fullmessage.length; i++) {
        final String linkFromFile = _fullmessage[i].split(' -> ').last;

        if (enableLog) {
          print('linkFromFile====>$linkFromFile');
        }
        print('map.keys->${map.keys}');
        print('map.keys->${map.keys.contains(linkFromFile)}');
        if (map.keys.contains(linkFromFile)) {
          _fullmessage[i] = _fullmessage[i].replaceAll(
              RegExp('^l'), map[_fullmessage[i].split(' -> ').last]);
          // f.remove(f.first);r
        }
      }
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------

    if (enableLog) {
      print(_fullmessage);
    }
    _fullmessage.removeWhere((String element) {
      //查找 -> ' .' 这个所在的行数
      return element.endsWith(' .');
    });
    final int currentIndex = _fullmessage.indexWhere((String element) {
      //查找 -> ' ..' 这个所在的行数
      return element.endsWith(' ..');
    });
    if (currentIndex == -1) {
      _fileNodes.add(Directory.getPlatformDirectory('..'));
    }
    if (enableLog) {
      print('currentIndex-->$currentIndex');
    }
    // ls 命令输出有空格上的对齐，不能用 list.split 然后以多个空格分开的方式来解析数据
    // 因为有的文件(夹)存在空格
    if (_fullmessage.isNotEmpty) {
      _startIndex = _fullmessage.first.indexOf(
        RegExp(':[0-9][0-9] '),
      ); //获取文件名开始的地址
      _startIndex += 4;
      if (enableLog) {
        print('startIndex===>>>$_startIndex');
      }
      if (path == '/') {
        //如果当前路径已经是/就不需要再加一个/了
        for (int i = 0; i < _fullmessage.length; i++) {
          FileEntity fileEntity;
          if (_fullmessage[i].startsWith(RegExp('-|l'))) {
            fileEntity = File.getPlatformFile(
              path + _fullmessage[i].substring(_startIndex),
              _fullmessage[i],
            );
          } else {
            fileEntity = Directory.getPlatformDirectory(
              path + _fullmessage[i].substring(_startIndex),
              info: _fullmessage[i],
            );
          }
          _fileNodes.add(fileEntity);
        }
      } else {
        for (int i = 0; i < _fullmessage.length; i++) {
          FileEntity fileEntity;
          if (_fullmessage[i].startsWith(RegExp('-|l'))) {
            fileEntity = File.getPlatformFile(
              '$path/' + _fullmessage[i].substring(_startIndex),
              _fullmessage[i],
            );
          } else {
            fileEntity = Directory.getPlatformDirectory(
              '$path/' + _fullmessage[i].substring(_startIndex),
              info: _fullmessage[i],
            );
          }
          _fileNodes.add(fileEntity);
        }
      }
    }

    return _fileNodes;
  }
}
