import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/my_home_controller.dart';

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
            if (controller.videoPath.isEmpty) {
              return InkWell(
                onTap: controller.urlValue.isNotEmpty
                    ? (!controller.isExecuting.value
                        ? () async {
                            final recordResult = await controller.startRecord();
                            if (recordResult) {
                              Get.snackbar("",
                                  "Đã ghi video vào thư mục: ${controller.videoPath.value}");
                              controller.player
                                  .stop()
                                  .whenComplete(() => controller.replay());
                            } else {
                              log('$runtimeType,${DateTime.now()} recordResult : $recordResult');
                            }
                          }
                        : null)
                    : null,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: controller.urlValue.isNotEmpty
                        ? (controller.isExecuting.value
                            ? Colors.grey
                            : Colors.amber)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: controller.isExecuting.value
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        controller.isExecuting.value
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
                          controller.isExecuting.value ? 'Đang ghi' : 'Bắt đầu',
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
              onTap: () {
                controller.player.play();
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.amber,
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
