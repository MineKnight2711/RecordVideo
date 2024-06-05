import 'dart:developer';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/multi_choice_item.dart';
import 'ai_feature_item.dart';
import '../controller/my_home_controller.dart';
import 'buttons.dart';

// link rtsp
// duration
// folder

class MyHomePage extends GetView<MyHomeController> {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Colors.grey.withOpacity(0.1),
        height: height,
        child: Row(
          children: [
            //camera view
            Container(
              width: width * 0.7,
              height: height,
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width * 0.7 * 0.7,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z \u00C0-\u1EF9]")),
                      ],
                      decoration:
                          const InputDecoration(hintText: 'Tên file...'),
                      controller: controller.fileNameController,
                      onChanged: (value) {
                        controller.onFileNameChange(value: value);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        SizedBox(
                          width: width * 0.7 * 0.7,
                          child: TextField(
                            decoration:
                                const InputDecoration(hintText: 'Rtsp url'),
                            controller: controller.urlController,
                            onChanged: (value) {
                              controller.onUrlChange(value: value);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                            child: SizedBox(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black.withOpacity(0.2),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            height: 48,
                            child: Obx(() {
                              return DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Chọn thời gian',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: timeItems
                                      .map(
                                        (String item) =>
                                            DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  value: controller.selectionTime.value,
                                  onChanged: (value) {
                                    controller.onTimeChange(value: value ?? '');
                                  },
                                ),
                              );
                            }),
                          ),
                        )),
                        const Text(
                          'phút',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  //button
                  const PlayButton(),
                  const SizedBox(
                    height: 16,
                  ),
                  // camera view
                  Container(
                    width: width * 0.6,
                    height: width * 0.6 * 9 / 16,
                    // color: Colors.grey.withOpacity(0.5),
                    alignment: Alignment.topLeft,
                    child: Video(
                      width: (width / 2) * 16 / 9,
                      wakelock: true,
                      aspectRatio: 16 / 9,
                      controller: controller.playerController,
                      // controls: (state) {
                      //   log('$runtimeType, VideoState : $state');
                      //   return const SizedBox();
                      // },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: height,
              width: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 24),
              color: Colors.grey,
            ),
            //setting feature list
            Expanded(
              child: Container(
                  height: height,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemBuilder: (context, index) {
                                final aiFeature =
                                    controller.aiFeatureList[index];
                                return AiFeatureItem(
                                  aiFeature: aiFeature,
                                  onCheckChange: (item) {
                                    controller.onCheckChange(aiFeature: item);
                                  },
                                  onClickExpand: (item) {
                                    controller.onClickExpand(aiFeature: item);
                                  },
                                  onClickAddData: (item) {
                                    _showDialog(
                                        aiFeature: item,
                                        onPressAddData: (aiFeature, value) {
                                          controller.addData(
                                              aiFeature: aiFeature,
                                              data: value);
                                        });
                                  },
                                  onPressedDeleteData: (aiFeature, dataItem) {
                                    controller.removeData(
                                        aiFeature: aiFeature, data: dataItem);
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 8,
                                );
                              },
                              itemCount: controller.aiFeatureList.length);
                        }),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        height: 40,
                        child: Obx(
                          () => TextButton(
                            onPressed: controller.urlValue.isNotEmpty &&
                                    !controller.checkFeatureList() &&
                                    controller.videoPath.value.isNotEmpty
                                ? () {}
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: controller.urlValue.isNotEmpty &&
                                          !controller.checkFeatureList() &&
                                          controller.videoPath.value.isNotEmpty
                                      ? Colors.amber
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 8),
                              child: const Text(
                                'Lưu',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog({
    required MultiChoiceItem aiFeature,
    required Function(MultiChoiceItem, String) onPressAddData,
  }) {
    TextEditingController textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Thêm dữ liệu"),
        actions: [
          Container(
            color: Colors.transparent,
            child: TextField(
              decoration: const InputDecoration(hintText: 'Thêm dữ liệu'),
              controller: textController,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Huỷ"),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    log('$runtimeType, data: ${textController.text}');
                    if (textController.text.isNotEmpty == true) {
                      onPressAddData.call(aiFeature, textController.text);
                    }
                  },
                  child: const Text("Thêm"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
