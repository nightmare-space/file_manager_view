import 'package:app_manager/app_manager.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:global_repository/global_repository.dart';

class AppSelectController extends GetxController {
  List<AppInfo> apps = [];
  @override
  void onInit() {
    super.onInit();
    getAppList();
  }

  Future<void> getAppList() async {
    Get.put(CheckController());
    apps = await AppUtils.getAllAppInfo(
      appChannel: AppManager.globalInstance.appChannel!,
    );
    update();
  }
}
