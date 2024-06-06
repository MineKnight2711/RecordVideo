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

const humanDetect = 'HUMAN_DETECTED';
const crowdDetect = 'CROWD_DETECTED';
const licensePlate = 'LICENSE_PLATE_DETECTED';
const faceDetect = 'FACE_DETECTED';
const fireDetect = 'FIRE_DETECTED';
const fallDetect = 'FALLING_DETECTED';

const int recordMinutes = 5;

class MyHomeController extends GetxController {
  late final Player player;

  late final VideoController playerController;

  TextEditingController urlController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();

  //obs
  final RxBool isExecuting = false.obs;
  final RxBool isReplay = false.obs;
  var selectionTimeObs = '1'.obs;
  var urlValueObs = ''.obs;
  var fileNameObs = ''.obs;
  var videoPathObs = ''.obs;
  var folderPathObs = ''.obs;

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
    fileNameController.text = fileNameObs.value = _formattedDate();

    urlController.text = urlValueObs.value =
        "rtsp://admin:Insen181@192.168.1.8:5541/cam/realmonitor?channel=1&subtype=1";

    aiFeatureList.value = _generateMultiChoiceItemList();
  }

  bool checkFeatureList() {
    return aiFeatureList.every((item) => item.checkEmptyData());
  }

  // handle value change
  void onTimeChange({required String value}) {
    selectionTimeObs.value = value;
    log('$runtimeType,  ${DateTime.now()} selectedValue: ${selectionTimeObs.value}');
  }

  void replay() {
    isReplay.value = true;
    player
        .open(Media("file:///${videoPathObs.value}"), play: false)
        .whenComplete(
          () => player.stream.completed.listen((event) {
            log('$runtimeType,  ${DateTime.now()} replay completed: $event');
            isReplay.value = false;
          }),
        )
        .catchError((e) {
      log('$runtimeType,  ${DateTime.now()} replay error: $e');
    });
  }

  Future<bool> startRecord() async {
    log('$runtimeType, start record url: ${urlValueObs.value}, fileName  ');
    player.open(Media(urlValueObs.value));
    final runCommandResult = await runCommandLine(
        url: urlValueObs.value, fileName: fileNameObs.value);
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

  void stopRecord() {
    log('$runtimeType,  ${DateTime.now()} stop record');
    player.stop();
    isExecuting.value = false;
  }

  Future<bool> runCommandLine(
      {required String url, required String fileName}) async {
    isExecuting.value = true;

    Completer<bool> complete = Completer();

    final timeStamp = int.parse(selectionTimeObs.value) * recordMinutes;

    final path = await _createDirectory();

    final command =
        'ffmpeg -i "$url" -reset_timestamps 1 -c copy -f segment -strftime 1 -segment_time $timeStamp -t $timeStamp $path\\$fileName.mp4';
    log('$runtimeType,  ${DateTime.now()} runCommandLine : $command ');

    await Process.run(
      command,
      [],
    ).then((result) {
      if (result.exitCode == 0) {
        complete.complete(true);
        isExecuting.value = false;
        fileNameController.text = '';
        videoPathObs.value = "$path\\$fileName.mp4";
        folderPathObs.value = path;
        log('$runtimeType,  ${DateTime.now()} runCommandLine video path: ${videoPathObs.value}  ');
      } else {
        complete.complete(false);
        log('$runtimeType,  ${DateTime.now()} runCommandLine error: ${result.exitCode}  ');
      }
    });
    // log('$runtimeType,  ${DateTime.now()} runCommandLine result: ${processResult.exitCode}  ');
    return complete.future;
  }

  String _formattedDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
  }

  void onUrlChange({required String value}) {
    log('$runtimeType, On url change value: $value');
    urlValueObs.value = value;
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

  void exportData() async {
    List<DetectionInfo> detections = [];
    for (var aiFeature in aiFeatureList) {
      if (aiFeature.isSelected == true && aiFeature.data.isNotEmpty == true) {
        detections.add(
          DetectionInfo(type: aiFeature.id, events: aiFeature.getEvents()),
        );
      }
    }
    VideoInfo videoInfo = VideoInfo(
      createdTime: DateTime.now().millisecondsSinceEpoch,
      detections: detections,
      duration: int.parse(selectionTimeObs.value) * recordMinutes,
      videoName: fileNameObs.value,
    );
    /*
    {
	"video_name":<string>,
	"duration":<int>,
	"detections":[
		{
		 "type":<string>,
		 "events":[<string>]
		}
	],
	"created_time":<int>
}
     */
    log('$runtimeType, Export data: ${videoInfo.toString()}');
    final file = File("${folderPathObs.value}/${fileNameObs.value}.txt");
    file.writeAsString(videoInfo.toString());
  }

  void addData(
      {required MultiChoiceItem aiFeature,
      required String data,
      required String countEvent}) {
    final result = <MultiChoiceItem>[];
    for (var element in aiFeatureList) {
      if (element.id == aiFeature.id) {
        for (int i = 0; i < int.parse(countEvent); i++) {
          element.data.add(DataItem(id: const Uuid().v1(), value: data));
        }
        element.isSelected = data.isNotEmpty;
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
        element.isSelected = element.data.isNotEmpty;
      }
      result.add(element);
    }
    aiFeatureList.value = result;
    log('$runtimeType, Add data: $aiFeatureList');
  }

  void onCheckChange({required MultiChoiceItem aiFeature}) {
    // final result = <MultiChoiceItem>[];
    // for (var element in aiFeatureList) {
    //   if (element.id == aiFeature.id) {
    //     element.isSelected = !(element.isSelected ?? false);
    //   }
    //   result.add(element);
    // }
    // aiFeatureList.value = result;
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
      title: 'Fire Detect',
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
