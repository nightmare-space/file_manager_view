import 'package:file_manager_view/io/interface/file_entity.dart';
import 'package:path/path.dart' as p;

extension EntityExt on FileEntity {
  int compareTo(FileEntity other) {
    if (isFile && !other.isFile) {
      return 1;
    }
    if (!isFile && other.isFile) {
      return -1;
    }
    return path.toLowerCase().compareTo(other.path.toLowerCase());
  }

  String get name => p.basename(path);
}
