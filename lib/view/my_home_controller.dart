import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const humanDetect = 'human_detect';
const crowdDetect = 'crowd_detect';
const licensePlate = 'license_plate';
const faceDetect = 'face_detect';
const fireDetect = 'fire_detect';
const fallDetect = 'fall_detect';
final  timeItems = [
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

    void initData(){
      aiFeatureList.value = _generateMultiChoiceItemList();
    }

  // handle value change
  void onTimeChange({required String value}){
    selectionTime.value = value;
  }

  void startRecord(){
    log('$runtimeType, start record url: ${urlValue.value}, fileName  ');
    runCommandLine(url: urlValue.value, fileName:'abc');
  }

  void runCommandLine({required String url, required String fileName}) async {
    log('$runtimeType, ${DateTime.now()} testRunCommandLine');
    //  player.open(Media(
    //     url));
    ProcessResult result = await Process.run(
        'ffmpeg -i "rtsp://admin:Insen181@192.168.1.8:5541/cam/realmonitor?channel=1&subtype=1" -reset_timestamps 1 -c copy -f segment -strftime 1 -segment_time 60 -t 60 video-%Y-%m-%d_%H-%M-%S.mp4',
        []);
    log('$runtimeType,  ${DateTime.now()} testRunCommandLine result: ${result.stdout.toString()} ');
  }

  void onUrlChange({required String value}){
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
  
  void addData({required MultiChoiceItem aiFeature, required String data}){
    final result = <MultiChoiceItem>[];
    for (var element in aiFeatureList) {
      if (element.id == aiFeature.id) {
        element.data?.add(DataItem(id: const Uuid().v1(),
            value: data
        )
        );
      }
      result.add(element);
    }
    aiFeatureList.value = result;
    log('$runtimeType, Add data: ${aiFeatureList.value}');
  }

  void removeData({required MultiChoiceItem aiFeature, required DataItem data}){
    final result = <MultiChoiceItem>[];
    for (var element in aiFeatureList) {
      if (element.id == aiFeature.id) {
       element.data?.remove(data);
      }
      result.add(element);
    }
    aiFeatureList.value = result;
    log('$runtimeType, Add data: ${aiFeatureList.value}');
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
  List<MultiChoiceItem> _generateMultiChoiceItemList(){
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