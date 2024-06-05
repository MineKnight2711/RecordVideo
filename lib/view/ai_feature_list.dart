import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record_video/controller/my_home_controller.dart';
import 'package:record_video/models/models.dart';
import 'package:record_video/widgets/dropdown.dart';

import 'ai_feature_item.dart';

class AiFeatureList extends StatelessWidget {
  final MyHomeController controller;
  const AiFeatureList({super.key,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
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
                          context: context,
                            aiFeature: item,
                            onPressAddData: (aiFeature, value,countEvent) {
                              controller.addData(
                                  aiFeature: aiFeature,
                                  data: value,
                                  countEvent: countEvent,
                              );
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
                    () {
                  final canExportData =
                      controller.urlValueObs.isNotEmpty &&
                          !controller.checkFeatureList() &&
                          controller.videoPathObs.value.isNotEmpty;
                  return  TextButton(
                    onPressed: canExportData
                        ? () {
                      controller.exportData();
                    }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                          color: canExportData
                              ? Colors.amber
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 8),
                      child: const Text(
                        'Xuất dữ liệu',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }


            ),
          )
        ],
      ),
    );
  }

  void _showDialog({
    required BuildContext context,
    required MultiChoiceItem aiFeature,
    required Function(MultiChoiceItem, String, String) onPressAddData,
  }) {
    log('$runtimeType, Show dialog add event');
    TextEditingController textController = TextEditingController();
    String countEvent = '1';
    Get.dialog(
      AlertDialog(
        title: const Text("Thêm dữ liệu"),
        actions: [
          Container(
            // width: MediaQuery.of(context).size.width/5,
            color: Colors.transparent,
            child: Row(
              children: [
               SizedBox(
                 width: 300,
                 child:  TextField(
                   decoration: const InputDecoration(hintText: 'Dữ liệu'),
                   controller: textController,
                 ),
               ),
                Expanded(child: DropDown(
                  title: 'Số lần',
                    items:List.generate(20, (index) => (index+1).toString()),
                    selectedValue:countEvent,
                    onChanged:(value){
                      // controller.onTimeChange(value: value);
                      countEvent = value;
                      log('$runtimeType, onChanged count: $countEvent');
                    }
                ),
                ),
                const Text(
                  'lần',
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
                      onPressAddData.call(aiFeature, textController.text,countEvent);
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
