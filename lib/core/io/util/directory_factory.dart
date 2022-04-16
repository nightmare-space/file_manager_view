import 'package:file_manager_view/core/io/impl/directory_browser.dart';
import 'package:file_manager_view/core/io/impl/directory_windows.dart';
import 'package:file_manager_view/core/io/interface/directory.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class DirectoryFactory {
  static Directory getPlatformDirectory(
    String path, {
    String info = '',
    Executable shell,
  }) {
    shell ??= YanProcess();
    if (GetPlatform.isWeb) {
      return DirectoryBrowser(path, info: info, shell: shell);
    }
    if (GetPlatform.isWindows) {
      return DirectoryWindows(path, info: info, shell: shell);
    } else if (GetPlatform.isMacOS) {
      return DirectoryBrowser(path, info: info, shell: shell);
    } else if (GetPlatform.isAndroid) {
      return DirectoryBrowser(path, info: info, shell: shell);
    }
    throw '没有平台对应的实现';
  }
}
