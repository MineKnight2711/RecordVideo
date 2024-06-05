import 'package:get/get.dart';

import '../controller/my_home_controller.dart';

class MyHomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyHomeController());
  }
}
