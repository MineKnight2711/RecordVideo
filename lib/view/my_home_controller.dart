import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:record_video/extension/multiple_choice_extension.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const humanDetect = 'human_detect';
const crowdDetect = 'crowd_detect';
const licensePlate = 'license_plate';
const faceDetect = 'face_detect';
const fireDetect = 'fire_detect';
const fallDetect = 'fall_detect';

final timeItems = [
  '1',
  '2',
  '3',
  '4',
  '5',
];

class MyHomeController extends GetxController {
  TextEditingController urlController = TextEditingController();

  //obs
  var selectionTime = '1'.obs;
  var urlValue = ''.obs;
  var aiFeatureList = <MultiChoiceItem>[].obs;

  void initData() {
    urlValue.value =
        "rtsp://admin:Insen181@192.168.1.8:5541/cam/realmonitor?channel=1&subtype=1";
    aiFeatureList.value = _generateMultiChoiceItemList();
  }

  bool checkFeatureList() {
    return aiFeatureList.every((item) => item.checkEmptyData());
  }

  // handle value change
  void onTimeChange({required String value}) {
    selectionTime.value = value;
    log('$runtimeType,  ${DateTime.now()} selectedValue: ${selectionTime.value}');
  }

  void startRecord() async {
    log('$runtimeType, start record url: ${urlValue.value}, fileName  ');
    if (urlValue.value.isEmpty) {
      return;
    }
    final runCommandResult =
        await runCommandLine(url: urlValue.value, fileName: 'abc');
    log('$runtimeType, runCommandResult: $runCommandResult ');
  }

  Future<bool> runCommandLine(
      {required String url, required String fileName}) async {
    Completer<bool> complete = Completer();
    final timeStamp = int.parse(selectionTime.value) * 60;
    final command =
        'ffmpeg -i "$url" -reset_timestamps 1 -c copy -f segment -strftime 1 -segment_time $timeStamp -t $timeStamp video-%Y-%m-%d_%H-%M-%S.mp4';
    log('$runtimeType,  ${DateTime.now()} runCommandLine : $command ');

    ProcessResult result = Process.runSync(
      command,
      [],
    );

    if (result.exitCode == 0) {
      complete.complete(true);
    } else {
      complete.complete(false);
    }
    log('$runtimeType,  ${DateTime.now()} runCommandLine result: ${result.pid}  ');
    return complete.future;
  }

  void onUrlChange({required String value}) {
    log('$runtimeType, On url change value: $value');
    urlValue.value = value;
  }

  void onClickExpand({required MultiChoiceItem aiFeature}) {
    final result = <MultiChoiceItem>[];
    for (var element in aiFeatureList) {
      if (element.id == aiFeature.id) {
        element.isExpanded = !(element.isExpanded ?? false);
      }
      result.add(element);
    }
    aiFeatureList.value = result;
  }

  void addData({required MultiChoiceItem aiFeature, required String data}) {
    final result = <MultiChoiceItem>[];
    for (var element in aiFeatureList) {
      if (element.id == aiFeature.id) {
        element.data.add(DataItem(id: const Uuid().v1(), value: data));
      }
      result.add(element);
    }
    aiFeatureList.value = result;
    log('$runtimeType, Add data: $aiFeatureList');
  }

  void removeData(
      {required MultiChoiceItem aiFeature, required DataItem data}) {
    final result = <MultiChoiceItem>[];
    for (var element in aiFeatureList) {
      if (element.id == aiFeature.id) {
        element.data.remove(data);
      }
      result.add(element);
    }
    aiFeatureList.value = result;
    log('$runtimeType, Add data: $aiFeatureList');
  }

  void onCheckChange({required MultiChoiceItem aiFeature}) {
    final result = <MultiChoiceItem>[];
    for (var element in aiFeatureList) {
      if (element.id == aiFeature.id) {
        element.isSelected = !(element.isSelected ?? false);
      }
      result.add(element);
    }
    aiFeatureList.value = result;
  }

  // init data
  List<MultiChoiceItem> _generateMultiChoiceItemList() {
    final result = <MultiChoiceItem>[];
    result.add(MultiChoiceItem(
      id: humanDetect,
      title: 'Human Detect',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: crowdDetect,
      title: 'Crowd Detect',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: licensePlate,
      title: 'License Plate',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: faceDetect,
      title: 'Face Detect',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: fireDetect,
      title: 'Fire Fetect',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: fallDetect,
      title: 'Fall Detect',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));

    return result;
  }
}
