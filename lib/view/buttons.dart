import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
            if (controller.videoPathObs.isEmpty) {
              return InkWell(
                onTap: controller.urlValueObs.isNotEmpty
                    ? (!controller.isExecuting.value
                        ? () async {
                            final recordResult = await controller.startRecord();
                            if (recordResult) {
                              Get.snackbar("",
                                  "Đã ghi video vào thư mục: ${controller.videoPathObs.value}");
                              controller.player
                                  .stop()
                                  .whenComplete(() => controller.replay());
                            } else {
                              log('$runtimeType,${DateTime.now()} recordResult : $recordResult');
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
              onTap: controller.isReplay.value
                  ? null
                  : () {
                      controller.player.play();
                    },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: controller.isReplay.value ? Colors.grey : Colors.amber,
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
