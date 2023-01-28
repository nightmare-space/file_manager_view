import 'package:dio/dio.dart';
import 'package:file_manager_view/core/io/extension/extension.dart';
import 'package:file_manager_view/core/io/impl/directory_browser.dart';
import 'package:file_manager_view/core/io/interface/io.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart';

class DeleteFile extends StatefulWidget {
  const DeleteFile({Key ?key,required this.entity}) : super(key: key);
  final FileEntity entity;

  @override
  State<DeleteFile> createState() => _DeleteFileState();
}

class _DeleteFileState extends State<DeleteFile> {
  late TextEditingController textEditingController;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(
      text: basename(widget.entity.path),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(12.w),
        child: SizedBox(
          width: 300.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 8.w,
              ),
              Text(
                '是否删除 ${widget.entity.name}?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.w,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      TextButton(
                        onPressed: () async {
                          FileManagerController fileManagerController =
                              Get.find();
                          String path = widget.entity.path;
                          Directory dir = fileManagerController.dir;
                          late Uri uri;
                          if (dir is DirectoryBrowser && dir.addr != null) {
                            uri = Uri.tryParse(dir.addr)!;
                          }
                          try {
                            var response = await Dio().get<String>(
                              '$uri/delete',
                              queryParameters: {'path': path},
                            );
                          } catch (e) {
                            Log.e('$this error ->$e');
                          }
                          focusNode.unfocus();
                          fileManagerController.updateFileNodes();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '确定',
                          style: TextStyle(color: Color(0xffee0000)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
