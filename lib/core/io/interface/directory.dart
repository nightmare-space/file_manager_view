

import 'file_entity.dart';

abstract class Directory extends FileEntity {
 
  Future<List<FileEntity>> list();

  @override
  String toString() {
    return 'path : $path';
  }
}
