import 'package:app_manager/app_manager.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/src/utils/screen_util.dart';

import 'app_select_controller.dart';

class AppSelect extends StatefulWidget {
  const AppSelect({Key? key}) : super(key: key);

  @override
  _AppSelectState createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {
  AppManagerController controller = Get.put((AppManagerController()));
  String filter = '';

  @override
  void initState() {
    super.initState();
    Get.put(CheckController());
    Get.put(IconController());
    controller.getUserApp();
  }

  @override
  void dispose() {
    Get.delete<AppManagerController>();
    Get.delete<CheckController>();
    Get.delete<IconController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
          child: SearchBox(
            onInput: (data) {
              filter = data;
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: GetBuilder<AppManagerController>(
            init: AppManagerController(),
            autoRemove: false,
            builder: (context) {
              return AppListPage(
                filter: filter,
                appList: context.userApps,
              );
            },
          ),
        ),
      ],
    );
  }
}
