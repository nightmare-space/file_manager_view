import 'dart:io';

import 'package:file_manager_view/file_manager_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signale/signale.dart';

// 预览图片的组件
class PreviewImage extends StatefulWidget {
  const PreviewImage({Key key, this.path, this.tag}) : super(key: key);
  final String path;
  // hero
  final String tag;
  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  String path;

  @override
  void initState() {
    super.initState();
    path = getRemotePath(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    Log.e(widget.path);
    Log.i(path);
    return Material(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: widget.tag,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: path.startsWith('http')
                  ? Image.network(path)
                  : Image.file(File(path)),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.clear),
              ),
            ),
          )
        ],
      ),
    );
  }
}
