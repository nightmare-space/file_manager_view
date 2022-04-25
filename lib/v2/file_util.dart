import 'package:file_manager_view/v2/ext_util.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

import 'preview_image.dart';
import 'preview_text.dart';
import 'video.dart';

class FileUtil {
  static void openFile(String path) {
    if (path.isImg) {
      Get.to(PreviewImage(
        path: path,
        tag: path,
      ));
    } else if (path.isVideo) {
      Get.to(
        SerieExample(
          path: path,
        ),
      );
    } else if (path.isText) {
      Get.to(
        PreviewText(
          path: path,
        ),
      );
    } else {
      OpenFile.open(path);
    }
  }
}
