import 'package:file_manager_view/config/config.dart';
import 'package:file_manager_view/controller/clipboard_controller.dart';
import 'package:file_manager_view/core/io/extension/extension.dart';
import 'package:file_manager_view/core/io/interface/io.dart';
import 'package:file_manager_view/v2/icon.dart';
import 'package:file_manager_view/widgets/file_manager_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:signale/signale.dart';

class GridFileItem extends StatefulWidget {
  const GridFileItem({
    Key? key,
    required this.entity,
    required this.onTap,
    required this.windowType,
  }) : super(key: key);
  final FileEntity entity;
  final void Function() onTap;
  final WindowType windowType;

  @override
  State<GridFileItem> createState() => _GridFileItemState();
}

class _GridFileItemState extends State<GridFileItem> {
  FileSelectController clipboardController = Get.find();
  @override
  Widget build(BuildContext context) {
    FileEntity fileEntity = widget.entity;
    Widget icon;
    if (fileEntity.isDirectory) {
      icon = SvgPicture.asset(
        '${Config.flutterPackage}assets/icon/dir.svg',
        width: 32.w,
        height: 32.w,
        color: Theme.of(context).primaryColor,
      );
    } else {
      icon = getIconByExt(fileEntity.path);
    }
    return InkWell(
      onTap: () {
        if (widget.windowType == WindowType.selectFile && widget.entity.isFile) {
          Feedback.forLongPress(context);
          if (clipboardController.checkNodes.contains(fileEntity)) {
            clipboardController.removeCheck(widget.entity);
            setState(() {});
          } else {
            clipboardController.addCheck(widget.entity);
            setState(() {});
          }
        }
        widget.onTap.call();
      },
      child: LayoutBuilder(builder: (context, con) {
        Log.i('con : $con');
        return SizedBox(
          width: con.maxWidth,
          height: con.maxHeight,
          // color: Colors.red,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (clipboardController.checkNodes.contains(fileEntity))
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              Column(
                children: [
                  SizedBox(height: 12.w),
                  SizedBox(
                    width: con.maxWidth - 20.w,
                    height: con.maxHeight - 60.w,
                    child: icon,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      fileEntity.name,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12.w,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
