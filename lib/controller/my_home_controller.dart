import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
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
const int recordMinutes = 60;

class MyHomeController extends GetxController {
  late final Player player;

  late final VideoController playerController;

  TextEditingController urlController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();

  //obs
  final RxBool isExecuting = false.obs;
  var selectionTime = '1'.obs;
  var urlValue = ''.obs;
  var fileNameObs = ''.obs;
  var videoPath = ''.obs;

  var aiFeatureList = <MultiChoiceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
    _initControllerAndPlayer();
  }

  void _initControllerAndPlayer() {
    player = Player(
        configuration: const PlayerConfiguration(
      protocolWhitelist: ['tcp'],
      logLevel: MPVLogLevel.debug,
    ));
    playerController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );

    player.stream.log.listen((data) {
      log('$runtimeType, data: ${data.text}');
    });
  }

  void _initData() {
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

  void replay() async {
    await player
        .open(Media("file:///${videoPath.value}"), play: false)
        .whenComplete(
          () => player.stream.completed.listen((event) {
            log('$runtimeType,  ${DateTime.now()} replay completed: $event');
          }),
        )
        .catchError((e) {
      log('$runtimeType,  ${DateTime.now()} replay error: $e');
    });
  }

  Future<bool> startRecord() async {
    log('$runtimeType, start record url: ${urlValue.value}, fileName  ');
    player.open(Media(urlValue.value));
    final runCommandResult =
        await runCommandLine(url: urlValue.value, fileName: fileNameObs.value);
    log('$runtimeType, runCommandResult: $runCommandResult ');
    return runCommandResult;
  }

  Future<String> _createDirectory() async {
    final directory = await getApplicationDocumentsDirectory();

    final path = "${directory.path}\\Videos";

    final ifDirectoryExist = await File(path).exists();

    if (!ifDirectoryExist) {
      var directory = await Directory(path).create(recursive: true);

      log('$runtimeType,  ${DateTime.now()} file path : ${directory.path} ');
    }
    return path;
  }

  Future<bool> runCommandLine(
      {required String url, required String fileName}) async {
    isExecuting.value = true;

    Completer<bool> complete = Completer();

    final timeStamp = int.parse(selectionTime.value) * recordMinutes;

    final path = await _createDirectory();

    final saveFileName = fileName.isNotEmpty ? fileName : _formattedDate();

    final command =
        'ffmpeg -i "$url" -reset_timestamps 1 -c copy -f segment -strftime 1 -segment_time $timeStamp -t $timeStamp $path\\$saveFileName.mp4';
    log('$runtimeType,  ${DateTime.now()} runCommandLine : $command ');

    await Process.run(
      command,
      [],
    ).then((result) {
      if (result.exitCode == 0) {
        complete.complete(true);
        isExecuting.value = false;
        fileNameController.text = fileNameObs.value = '';

        videoPath.value = "$path\\$saveFileName.mp4";

        log('$runtimeType,  ${DateTime.now()} runCommandLine video path: ${videoPath.value}  ');
      } else {
        complete.complete(false);
        log('$runtimeType,  ${DateTime.now()} runCommandLine error: ${result.exitCode}  ');
      }
    });
    return complete.future;
  }

  String _formattedDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
  }

  void onUrlChange({required String value}) {
    log('$runtimeType, On url change value: $value');
    urlValue.value = value;
  }

  void onFileNameChange({required String value}) {
    value = value.replaceAll(' ', '_');
    log('$runtimeType, On url change value: $value');
    fileNameObs.value = value;
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
