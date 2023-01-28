import 'package:dio/dio.dart';
import 'package:file_manager_view/core/io/impl/directory_browser.dart';
import 'package:file_manager_view/core/io/interface/io.dart';
import 'package:file_manager_view/widgets/file_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart';

class RenameFile extends StatefulWidget {
  const RenameFile({Key? key, required this.entity}) : super(key: key);
  final FileEntity entity;

  @override
  State<RenameFile> createState() => _RenameFileState();
}

class _RenameFileState extends State<RenameFile> {
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
                height: 4.w,
              ),
              Text(
                '重命名',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8.w,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  autofocus: false,
                  // textInputAction: TextInputAction.done,
                  maxLines: 1,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      gapPadding: 0,
                      borderSide: const BorderSide(
                        width: 0,
                        color: Colors.transparent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      gapPadding: 0,
                      borderSide: const BorderSide(
                        width: 0,
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      gapPadding: 0,
                      borderSide: BorderSide(
                        width: 0,
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.w,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.fade,
                  ),
                  onSubmitted: (_) async {
                    Log.i('object');
                    FileManagerController fileManagerController = Get.find();
                    String path = widget.entity.path;
                    Directory dir = fileManagerController.dir;
                    late Uri uri;
                    if (dir is DirectoryBrowser && dir.addr != null) {
                      uri = Uri.tryParse(dir.addr)!;
                    }
                    try {
                      var response = await Dio().get<String>(
                        '$uri/rename',
                        queryParameters: {
                          'path': path,
                          'name': _,
                        },
                      );
                    } catch (e) {
                      Log.e('$this error ->$e');
                    }
                    focusNode.unfocus();
                    fileManagerController.updateFileNodes();
                  },
                  onEditingComplete: () async {},
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () async {
                      Log.i('object');
                      FileManagerController fileManagerController = Get.find();
                      String path = widget.entity.path;
                      Directory dir = fileManagerController.dir;
                      late Uri uri;
                      if (dir is DirectoryBrowser && dir.addr != null) {
                        uri = Uri.tryParse(dir.addr)!;
                      }
                      try {
                        var response = await Dio().get<String>(
                          '$uri/rename',
                          queryParameters: {
                            'path': path,
                            'name': textEditingController.text,
                          },
                        );
                      } catch (e) {
                        Log.e('$this error ->$e');
                      }
                      focusNode.unfocus();
                      fileManagerController.updateFileNodes();
                      Navigator.of(context).pop();
                    },
                    child: const Text('确定'),
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
