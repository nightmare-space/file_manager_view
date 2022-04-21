import 'package:file_manager_view/core/io/document/document.dart';
import 'package:file_manager_view/core/io/impl/directory_browser.dart';
import 'package:file_manager_view/core/io/interface/io.dart';
import 'package:file_manager_view/main.dart';
import 'package:file_manager_view/v2/ext_util.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'dart:io' as io;

Widget getIconByExt(String path) {
  FileManagerController fileManagerController = Get.find();
  Widget child;
  if (path.isVideo) {
    child = Image.asset(
      'assets/icon/video.png',
      width: 36.w,
      height: 36.w,
    );
  } else if (path.isPdf) {
    child = Image.asset(
      'assets/icon/pdf.png',
      width: 36.w,
      height: 36.w,
    );
  } else if (path.isDoc) {
    child = Image.asset(
      'assets/icon/doc.png',
      width: 36.w,
      height: 36.w,
    );
  } else if (path.isZip) {
    child = Image.asset(
      'assets/icon/zip.png',
      width: 36.w,
      height: 36.w,
    );
  } else if (path.isAudio) {
    child = Image.asset(
      'assets/icon/mp3.png',
      width: 36.w,
      height: 36.w,
    );
  } else if (path.isImg) {
    Directory dir = fileManagerController.dir;
    if (dir is DirectoryBrowser && dir.addr != null) {
      Uri uri = Uri.tryParse(
        (fileManagerController.dir as DirectoryBrowser).addr,
      );
      String perfix = 'http://${uri.host}:20000';
      path = (perfix + path).replaceAll('/sdcard', '');
    }
    return Hero(
      tag: path,
      child: GestureDetector(
        onTap: () {
          // Get.to(PreviewImage(path: path));
        },
        child: path.startsWith('http')
            ? Image(
                width: 36.w,
                height: 36.w,
                fit: BoxFit.cover,
                image: ResizeImage(
                  NetworkImage(path),
                  width: 36,
                ),
              )
            : Image(
                image: ResizeImage(
                  FileImage(io.File(path)),
                  width: 36,
                ),
                width: 36.w,
                height: 36.w,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  child ??= Image.asset(
    'assets/icon/other.png',
    width: 36.w,
    height: 36.w,
  );
  return GestureDetector(
    onTap: () {
      // OpenFile.open(path);
    },
    child: child,
  );
}
