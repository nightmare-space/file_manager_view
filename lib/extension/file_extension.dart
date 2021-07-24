import 'package:file_manager_view/io/interface/file_entity.dart';

extension FileExt on FileEntity {
  static final List<String> imagetype = <String>['jpg', 'png']; //图片的所有扩展名
  static final List<String> textType = <String>[
    'smali',
    'txt',
    'xml',
    'py',
    'sh',
    'dart'
  ]; //文本的扩展名
  bool isText() {
    final String type = path.replaceAll(RegExp('.*\\.'), '');
    return textType.contains(type);
  }

  bool isImg() {
    // Directory();
    // File
    final String type = path.replaceAll(RegExp('.*\\.'), '');
    return imagetype.contains(type);
  }
}
