import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:record_video/widgets/dropdown.dart';
import '../controller/my_home_controller.dart';
import '../widgets/custom_dialog.dart';
import 'ai_feature_list.dart';
import 'buttons.dart';

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
                vertical: 10,
                horizontal: 24,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.7 * 0.7,
                      child: Obx(
                        () => TextField(
                          enabled: controller.recordState.value !=
                              RecordState.recording,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[0-9a-zA-Z_\\- \u00C0-\u1EF9]")),
                          ],
                          decoration:
                              const InputDecoration(hintText: 'Tên file...'),
                          controller: controller.fileNameController,
                          onChanged: controller.onFileNameChange,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          SizedBox(
                            width: width * 0.7 * 0.7,
                            child: Obx(
                              () => TextField(
                                enabled: controller.recordState.value !=
                                    RecordState.recording,
                                decoration:
                                    const InputDecoration(hintText: 'Rtsp url'),
                                controller: controller.urlController,
                                onChanged: controller.onUrlChange,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Obx(
                              () {
                                return DropDown(
                                  isEnable: controller.recordState.value !=
                                      RecordState.recording,
                                  title: 'Chọn thời gian',
                                  items: List.generate(
                                      5, (index) => (index + 1).toString()),
                                  selectedValue:
                                      controller.selectionTimeObs.value,
                                  onChanged: controller.onTimeChange,
                                );
                              },
                            ),
                          ),
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
                    Row(
                      children: [
                        SizedBox(
                          width: width * 0.7 * 0.7,
                          child: TextField(
                            decoration:
                                const InputDecoration(hintText: 'Đường dẫn...'),
                            controller: controller.folderPathController,
                            readOnly: true,
                            // onChanged:(value){
                            //   controller.onUrlChange(value: value);
                            // }
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 30, top: 10),
                          height: height * 0.05,
                          width: width * 0.13,
                          child: Obx(
                            () => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    controller.folderPathObs.value.isEmpty
                                        ? Colors.amber
                                        : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: controller.recordState.value ==
                                      RecordState.waiting
                                  ? controller.folderPathObs.value.isEmpty
                                      ? () {
                                          seletedDirectory();
                                        }
                                      : () => Get.dialog(
                                            CustomDialog(
                                              title:
                                                  "Đường dẫn hiện tại\n${controller.folderPathObs.value}",
                                              message:
                                                  "Bạn có muốn chọn thư mục khác không?",
                                              icon: const Icon(
                                                Icons.help_outline_rounded,
                                                color: Colors.blue,
                                                size: 50,
                                              ),
                                              onOkPressed: () {
                                                seletedDirectory();
                                              },
                                              showCancelButton: true,
                                            ),
                                          )
                                  : null,
                              child: const Text(
                                "Chọn thư mục",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                    Center(
                      child: Container(
                        width: width * 0.6,
                        height: width * 0.6 * 9 / 16,
                        alignment: Alignment.topLeft,
                        child: Video(
                          width: (width / 2) * 16 / 9,
                          wakelock: true,
                          aspectRatio: 16 / 9,
                          controller: controller.playerController,
                          controls: (state) {
                            return Obx(
                              () => controller.recordState.value ==
                                          RecordState.recordFinished ||
                                      controller.recordState.value ==
                                          RecordState.replaying
                                  ? AdaptiveVideoControls(state)
                                  : const SizedBox(),
                            );
                          },
                        ),
                      ),
                    ),
                  ]),
            ),
            Container(
              height: height,
              width: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 24),
              color: Colors.grey,
            ),
            //setting feature list
            Expanded(
                child: AiFeatureList(
              controller: controller,
            )),
          ],
        ),
      ),
    );
  }

  seletedDirectory() async {
    final result = await controller.selectDirectory();
    switch (result) {
      case "Success":
        Get.back();
        break;
      case "InvalidDirectory":
        Get.dialog(
          const CustomDialog(
            title: "Lỗi",
            message:
                "Tên thư mục không được chứa khoảng trắng hoặc ký tự đặc biệt!\n Video sẽ không được lưu!",
            icon: Icon(
              Icons.help_outline_rounded,
              color: Colors.blue,
              size: 50,
            ),
            showCancelButton: true,
          ),
        );
        break;
      case "NoSeletedDirectory":
        //Xử lý không chọn thư mục nào
        Get.back();
        break;
      default:
    }
  }
}
