import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:file_manager_view/page/directory_select_page.dart';
import 'package:file_manager_view/page/file_select_page.dart';
import 'package:flutter/material.dart';

class FileManager {
  static Future<List<FileEntity>> pickFiles(BuildContext context) async {
    List<FileEntity> result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return FileSelectPage();
        },
      ),
    );
    return result;
  }

  static Future<String> pickDirectory(BuildContext context) async {
    String result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return DirectorySelectPage();
        },
      ),
    );
    return result;
  }
}
