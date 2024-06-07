import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/my_home_controller.dart';
import '../widgets/custom_dialog.dart';

class PlayButton extends GetView<MyHomeController> {
  const PlayButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 40,
        width: 200,
        child: Obx(() {
          if (controller.videoPathObs.isEmpty) {
            return ElevatedButton.icon(
              label: Text(
                controller.recordState.value == RecordState.recording
                    ? 'Đang ghi'
                    : 'Bắt đầu',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              icon: controller.recordState.value == RecordState.recording
                  ? Container(
                      height: 16,
                      width: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const SizedBox.shrink(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor:
                    controller.recordState.value == RecordState.recording
                        ? Colors.red.withOpacity(0.8)
                        : Colors.amber,
              ),
              onPressed: (controller.recordState.value == RecordState.waiting
                  ? () async {
                      final recordResult = await controller.startRecord();
                      log('$runtimeType,${DateTime.now()} recordResult : $recordResult');
                      if (recordResult == "NoPath") {
                        Get.dialog(const CustomDialog(
                          icon: Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 50),
                          title: "Bạn chưa chọn thư mục!",
                          message: "Bạn phải chọn thư mục để lưu video!",
                        ));
                      } else if (recordResult == "InvalidUrl") {
                        Get.dialog(const CustomDialog(
                          icon: Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 50),
                          title: "Lỗi!",
                          message: "Đường dẫn không đúng định dạng",
                        ));
                      }
                    }
                  : () {
                      controller.stopRecord();
                    }),
            );
          }
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor:
                  controller.recordState.value == RecordState.replaying
                      ? Colors.grey
                      : Colors.amber,
            ),
            onPressed: controller.recordState.value == RecordState.replaying
                ? null
                : () {
                    controller.replay();
                  },
            child: const Text(
              'Phát lại',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }),
      ),
    );
  }
}
