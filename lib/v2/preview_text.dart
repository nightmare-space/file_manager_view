import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewText extends StatefulWidget {
  const PreviewText({Key key, this.path}) : super(key: key);
  final String path;

  @override
  State<PreviewText> createState() => _PreviewTextState();
}

class _PreviewTextState extends State<PreviewText> {
  String data = '';
  @override
  void initState() {
    super.initState();
    Dio().get(widget.path).then((value) {
      data = value.data.toString();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          SingleChildScrollView(child: SelectableText(data)),
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
