// 通过判断文件节点的扩展名来显示对应的icon
import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/extension/file_entity_extension.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io' as io;

Widget getWidgetFromExtension(FileEntity fileNode, BuildContext context,
    [bool isFile = true]) {
  if (isFile) {
    if (fileNode.name.endsWith('.zip')) {
      return SvgPicture.asset(
        '${Config.flutterPackage}assets/icon/zip.svg',
        width: 20.0,
        height: 20.0,
        color: Theme.of(context).iconTheme.color,
      );
    } else if (fileNode.name.endsWith('.apk')) {
      return const Icon(
        Icons.android,
      );
    } else if (fileNode.name.endsWith('.mp4')) {
      return const Icon(
        Icons.video_library,
      );
    } else {
      if (fileNode.name.endsWith('.jpg') || fileNode.name.endsWith('.png')) {
        return Image(
          width: 30,
          height: 30,
          image: ResizeImage(
            FileImage(io.File(fileNode.path)),
            width: 30,
          ),
        );
        // return ItemImgHeader(
        //   fileNode: fileNode as AbstractNiFile,
        // );
      } else {
        return SvgPicture.asset(
          '${Config.flutterPackage}assets/icon/file.svg',
          width: 20.0,
          height: 20.0,
        );
      }
    }
  } else {
    return SvgPicture.asset(
      '${Config.flutterPackage}assets/icon/directory.svg',
      width: 20.0,
      height: 20.0,
      color: Theme.of(context).iconTheme.color,
    );
  }
}
