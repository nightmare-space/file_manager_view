import 'dart:io' as io;

import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:file_manager_view/core/io/interface/file.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:file_manager_view/core/io/util/directory_factory.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart';

import 'directory_unix.dart';

class DirectoryIOS extends FileEntity implements Directory {
  DirectoryIOS(String path, {String? info, Executable? shell}) {
    this.path = path;
    this.info = info;
  }
  @override
  Future<List<FileEntity>> list({
    bool verbose = false,
  }) async {
    final List<FileEntity> _fileNodes = <FileEntity>[];
    _fileNodes.add(DirectoryFactory.getPlatformDirectory(
      '$path${io.Platform.pathSeparator}..',
    ));
    List<String> message = await getIOSFullMessage(path);
    print(message.join('\n'));
    return getFilesFrom(message.cast<String>(), path);
    for (final io.FileSystemEntity fileSystemEntity in io.Directory(path).listSync()) {
      // print(io.FileStat.statSync(fileSystemEntity.path));
      // print(fileSystemEntity.statSync().modeString());
      if (fileSystemEntity is io.Directory) {
        // print(fileSystemEntity);
        _fileNodes.add(DirectoryFactory.getPlatformDirectory(fileSystemEntity.path));
      } else {
        _fileNodes.add(File.getPlatformFile(fileSystemEntity.path, ''));
      }
    }
    return _fileNodes;
  }
}

Future<List<String>> getIOSFullMessage(String path) async {
  List<String> message = [];
  for (final io.FileSystemEntity fileSystemEntity in io.Directory(path).listSync()) {
    print('fileSystemEntity -> $fileSystemEntity');
    if (fileSystemEntity is io.Directory) {
      StringBuffer buffer = StringBuffer();
      io.FileStat stat = fileSystemEntity.statSync();
      buffer.write('d${stat.modeString()} ');
      buffer.write(wrapSpace('0', stat.size.toString()));
      buffer.write('${stat.modified.fmTime()} ');
      buffer.write('${basename(fileSystemEntity.path)}');
      message.add(buffer.toString());
      // message.add('value')
    } else {
      StringBuffer buffer = StringBuffer();
      io.FileStat stat = fileSystemEntity.statSync();
      buffer.write('-${stat.modeString()} ');
      // buffer.write('0 ');
      // buffer.write('${stat.size} ');
      buffer.write(wrapSpace('0', stat.size.toString()));
      buffer.write('${stat.modified.fmTime()} ');
      buffer.write('${basename(fileSystemEntity.path)}');
      message.add(buffer.toString());
    }
  }
  return message;
}

String wrapSpace(String itemNumber, String size) {
  return ('$itemNumber $size').padRight(10);
}

extension TimeExt on DateTime {
  String fmTime() {
    StringBuffer buffer = StringBuffer();
    buffer.write('$year-${_twoDigits(month)}-${_twoDigits(day)} ');
    buffer.write('${_twoDigits(hour)}:${_twoDigits(minute)}');
    return buffer.toString();
  }
}

String _twoDigits(int n) {
  if (n >= 10) return "${n}";
  return "0${n}";
}
