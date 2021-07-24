import 'package:file_manager_view/extension/file_entity_extension.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class FileItemSuffix extends StatelessWidget {
  const FileItemSuffix({Key key, this.fileNode}) : super(key: key);

  final FileEntity fileNode;

  @override
  Widget build(BuildContext context) {
    if (fileNode.name.endsWith('_src') && fileNode.isDirectory)
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.build),
          onPressed: () {
            // showCustomDialog<void>(
            //   context: context,
            //   duration: const Duration(milliseconds: 200),
            //   child: ApktoolEncodeDialog(
            //     directory: fileNode as AbstractDirectory,
            //   ),
            // );
          },
        ),
      );
    if (fileNode.name.endsWith('apk'))
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.build),
          onPressed: () {
            // showCustomDialog<void>(
            //   context: context,
            //   duration: const Duration(milliseconds: 200),
            //   child: ApkToolDialog(
            //     fileNode: fileNode as AbstractNiFile,
            //   ),
            // );
          },
        ),
      );
    return const SizedBox();
  }
}
