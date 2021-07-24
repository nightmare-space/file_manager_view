// import 'dart:io';

// import 'package:file_manager_view/extension/file_entity_extension.dart';
// import 'package:file_manager_view/extension/file_extension.dart';
// import 'package:file_manager_view/global/controller/clipboard_controller.dart';
// import 'package:file_manager_view/global/instance/global.dart';
// import 'package:file_manager_view/io/interface/file_entity.dart';
// import 'package:flutter/material.dart';
// import 'package:global_repository/global_repository.dart';
// import 'package:path/path.dart' as p;

// import 'file_manager_controller.dart';

// final Map<String, double> historyOffset = <String, double>{};
// void itemOnTap({
//   @required FileEntity entity,
//   @required FileManagerController controller,
//   @required ScrollController scrollController,
//   @required BuildContext context,
// }) {
//   final Clipboards clipboards = Global.instance.clipboards;
//   if (clipboards.checkNodes.contains(entity)) {
//     Global.instance.clipboards.removeCheck(entity);
//     controller.notifyListeners();
//     return;
//   }
//   if (entity.name == '..') {
//     //清除所有已选择
//     clipboards.clearCheck();
//     //如果点了两个点的默认始终返上级目录
//     final String backPath = p.dirname(controller.dirPath);
//     controller.updateFileNodes(backPath);
//   } else if (!entity.isFile) {
//     //如果不是文件就进入这个文件夹
//     //进入文件夹前把当前文件夹浏览到的Offset保存下来
//     historyOffset[controller.dirPath] = scrollController.offset;
//     if (controller.dirPath == '/') {
//       //是否是最顶层文件夹的
//       controller.updateFileNodes('/${entity.name}');
//     } else {
//       controller.pageController.nextPage(
//         duration: Duration(milliseconds: 3000),
//         curve: Curves.easeIn,
//       );
//       controller.updateFileNodes('${controller.dirPath}/${entity.name}');
//     }
//   } else {
//     // --------------------------------
//     // 以下是当前节点是文件的情况
//     if (entity.isText()) {
//       // Navigator.of(context).push<void>(
//       //   MaterialPageRoute<void>(
//       //     builder: (BuildContext c) {
//       //       return TextEdit(
//       //         fileNode: entity as AbstractNiFile,
//       //       );
//       //     },
//       //   ),
//       // );
//     }

//     if (entity.isImg()) {
//       final List<FileEntity> _imagelist = <FileEntity>[];
//       for (final FileEntity entity in controller.fileNodes) {
//         if (entity.isImg()) {
//           _imagelist.add(entity);
//         }
//       }
//       final PageController pageController = PageController(
//         initialPage: _imagelist.indexOf(entity),
//       );
//       Navigator.of(context).push<void>(
//         MaterialPageRoute<void>(
//           builder: (_) {
//             return Hero(
//               tag: entity.path,
//               child: PageView.builder(
//                 controller: pageController,
//                 itemCount: _imagelist.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return Container(
//                     color: Colors.black,
//                     child: Image.file(
//                       File(_imagelist[index].path),
//                       //mode: ExtendedImageMode.Gesture,
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       );
//       // --------------------------------
//     }
//   }
// }

// void itemOnLongPress({
//   @required FileEntity entity,
//   @required BuildContext context,
//   @required FileManagerController controller,
// }) {
//   if (entity.name != '..') {
//     if (entity.name.endsWith('_dex')) {
//       // TODO
//     }
//     if (entity.name.endsWith('_src')) {
//       // TODO
//     }
//     // showCustomDialog<void>(
//     //   context: context,
//     //   child: Theme(
//     //     data: Theme.of(context),
//     //     child: LongPressDialog(
//     //       controller: controller,
//     //       fileNode: entity,
//     //     ),
//     //   ),
//     // );
//   }
// }
