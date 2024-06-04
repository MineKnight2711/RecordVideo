import 'dart:developer';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// import 'package:media_kit_video/media_kit_video.dart';

import '../models/multi_choice_item.dart';
import 'ai_feature_item.dart';
import 'my_home_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// link rtsp
// duration
// folder

class _MyHomePageState extends State<MyHomePage> {
  MyHomeController get myHomeController =>
      Get.put(MyHomeController(), permanent: false);
  late final Player player = Player(
      configuration: const PlayerConfiguration(
    // bufferSize: 5,
    protocolWhitelist: ['tcp'],
    logLevel: MPVLogLevel.debug,
  ));

  late final VideoController playerController = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      enableHardwareAcceleration: true,
    ),
  );

  @override
  void initState() {
    //  player.open(Media('rtsp://admin:Insen181@10.10.1.105:554/Streaming/channels/102'));
    _registerListener();
    myHomeController.initData();

    super.initState();
  }

  void _registerListener() {
    player.stream.log.listen((data) {
      log('$runtimeType, data: ${data.text}');
    });
  }

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
                    height: 48,
                    child: Row(
                      children: [
                        SizedBox(
                          width: width * 0.7 * 0.7,
                          child: TextField(
                            decoration:
                                const InputDecoration(hintText: 'Rtsp url'),
                            controller: myHomeController.urlController,
                            onChanged: (value) {
                              myHomeController.onUrlChange(value: value);
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
                                  value: myHomeController.selectionTime.value,
                                  onChanged: (value) {
                                    myHomeController.onTimeChange(
                                        value: value ?? '');
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
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => InkWell(
                              onTap: myHomeController.urlValue.isNotEmpty
                                  ? () {
                                      player.open(Media(
                                          myHomeController.urlValue.value));
                                      myHomeController.startRecord();
                                    }
                                  : null,
                              child: Container(
                                height: 40,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                decoration: BoxDecoration(
                                  color: myHomeController.urlValue.isNotEmpty
                                      ? Colors.amber
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Bắt đầu',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
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
                      controller: playerController,
                      controls: (state) {
                        return const SizedBox();
                      },
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
                                    myHomeController.aiFeatureList[index];
                                return AiFeatureItem(
                                  aiFeature: aiFeature,
                                  onCheckChange: (item) {
                                    myHomeController.onCheckChange(
                                        aiFeature: item);
                                  },
                                  onClickExpand: (item) {
                                    myHomeController.onClickExpand(
                                        aiFeature: item);
                                  },
                                  onClickAddData: (item) {
                                    _showDialog(
                                        aiFeature: item,
                                        onPressAddData: (aiFeature, value) {
                                          myHomeController.addData(
                                              aiFeature: aiFeature,
                                              data: value);
                                        });
                                  },
                                  onPressedDeleteData: (aiFeature, dataItem) {
                                    myHomeController.removeData(
                                        aiFeature: aiFeature, data: dataItem);
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 8,
                                );
                              },
                              itemCount: myHomeController.aiFeatureList.length);
                        }),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        height: 40,
                        child: Obx(
                          () => TextButton(
                            onPressed: myHomeController.urlValue.isNotEmpty &&
                                    !myHomeController.checkFeatureList()
                                ? () {}
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: myHomeController.urlValue.isNotEmpty &&
                                          !myHomeController.checkFeatureList()
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        TextEditingController textController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
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
                          Navigator.pop(context);
                        },
                        child: const Text("Huỷ"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
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
            );
          },
        );
      },
    );
  }
}
