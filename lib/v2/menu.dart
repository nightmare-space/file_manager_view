import 'package:file_manager_view/core/io/document/document.dart';
import 'package:file_manager_view/core/io/interface/file_entity.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class Menu extends StatefulWidget {
  const Menu({Key key, this.entity}) : super(key: key);
  final FileEntity entity;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(12.w),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 200.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  // String url;
                  Uri uri = Uri.tryParse(url);
                  String perfix = 'http://${uri.host}:8000';
                  String path = widget.entity.path.replaceAll('/sdcard', '');
                  await canLaunch(
                    Uri.encodeFull(
                      '$perfix$path',
                    ),
                  )
                      ? await launch(
                          Uri.encodeFull('$perfix$path' '?download=true'),
                        )
                      : throw 'Could not launch $url';
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  height: 48.w,
                  child: Align(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        '下载',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  Uri uri = Uri.tryParse(url);
                  String perfix = 'http://${uri.host}:8000';
                  String path = widget.entity.path.replaceAll('/sdcard', '');
                  await canLaunch(
                    Uri.encodeFull(
                      '$perfix$path',
                    ),
                  )
                      ? await launch(
                          Uri.encodeFull('$perfix$path'),
                        )
                      : throw 'Could not launch $url';
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  height: 48.w,
                  child: Align(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        '预览',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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
