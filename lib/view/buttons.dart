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
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            if (controller.videoPathObs.isEmpty) {
              return InkWell(
                onTap: controller.urlValueObs.isNotEmpty
                    ? (controller.recordState.value == RecordState.waiting
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
                            }
                          }
                        : () {
                            controller.stopRecord();
                          })
                    : null,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: controller.urlValueObs.isNotEmpty
                        ? Colors.amber
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Obx(
                    () => Row(
                      mainAxisAlignment:
                          controller.recordState.value == RecordState.recording
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.center,
                      children: [
                        controller.recordState.value == RecordState.recording
                            ? Container(
                                height: 16,
                                width: 16,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              )
                            : const SizedBox.shrink(),
                        Text(
                          controller.recordState.value == RecordState.recording
                              ? 'Đang ghi'
                              : 'Bắt đầu',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return InkWell(
              onTap: controller.recordState.value == RecordState.replaying
                  ? null
                  : () {
                      controller.replay();
                    },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: controller.recordState.value == RecordState.replaying
                      ? Colors.grey
                      : Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Phát lại',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
