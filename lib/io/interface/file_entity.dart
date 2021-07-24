import 'package:global_repository/global_repository.dart';

import 'directory.dart';
import 'file.dart';
import 'package:path/path.dart' as p;

abstract class FileEntity {
  XProcess shell;
  //这个名字可能带有->/x/x的字符
  String path;
  //完整信息
  String info;
  //文件创建日期

  String accessed = '';
  //文件修改日期
  String modified = '';
  //如果是文件夹才有该属性，表示它包含的项目数
  String itemsNumber = '';
  // 节点的权限信息
  String mode = '';
  // 文件的大小，isFile为true才赋值该属性
  String size = '';
  String uid = '';
  String gid = '';

  String get parentPath => p.dirname(path);
  bool get isFile => this is File;
  bool get isDirectory => this is Directory;

  @override
  String toString() {
    String type = 'file';
    if (this is Directory) {
      type = 'dir';
    }
    return 'type:$type path:$path';
  }

  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! FileEntity) {
      return false;
    }
    if (other is FileEntity) {
      final FileEntity entity = other;
      return path == entity.path;
    }
    return false;
  }

  @override
  int get hashCode => path.hashCode;
  Future<bool> delete() {
    throw UnimplementedError();
  }

  Future<bool> copy(File to) {
    throw UnimplementedError();
  }

  Future<bool> move(File to) {
    throw UnimplementedError();
  }

  Future<bool> rename(String name) {
    throw UnimplementedError();
  }
}
