import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
// ignore: unused_import
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

const int recordMinutes = 60;
const defaultFps = 15;
const url =
    "rtsp://admin:Insen181@192.168.1.8:5541/cam/realmonitor?channel=1&subtype=1";

enum RecordState { waiting, recording, recordFinished, replaying }

class MyHomeController extends GetxController {
  late final Player player;

  late final VideoController playerController;

  TextEditingController urlController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  TextEditingController folderPathController = TextEditingController();

  //obs
  final recordState = RecordState.waiting.obs;

  final RxString selectionTimeObs = '1'.obs;
  final RxString urlValueObs = ''.obs;
  final RxString fileNameObs = ''.obs;
  final RxString videoPathObs = ''.obs;
  final RxString folderPathObs = ''.obs;

  final aiFeatureList = <MultiChoiceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
    _initControllerAndPlayer();
  }

  @override
  void refresh() {
    super.refresh();
    player.stop();
    _refreshData();
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
      final text = data.text;
      if (text.contains('Container reported FPS')) {
        final fps =
            double.parse(text.substring('Container reported FPS: '.length));

        log('$runtimeType,  ${DateTime.now()} Container reported FPS: $fps');
        // if fps = 15 start command record video
        if (fps == defaultFps) {
          //Start command record video
          runCommandLine(fileName: fileNameObs.value, url: urlValueObs.value);
        } else {
          // stopRecord();
        }
      }
    });
  }

  void _refreshData() {
    recordState.value = RecordState.waiting;
    selectionTimeObs.value = '1';
    videoPathObs.value = folderPathObs.value = folderPathController.text = '';
    fileNameObs.value = fileNameController.text = _formattedDate();
    urlValueObs.value = url;
    aiFeatureList.clear();
    aiFeatureList.value = _generateMultiChoiceItemList();
  }

  void _initData() {
    fileNameController.text = fileNameObs.value = _formattedDate();
    urlValueObs.value = urlController.text = url;

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
    recordState.value = RecordState.replaying;

    player
        .play()
        .whenComplete(
          () => player.stream.completed.listen((event) {
            if (event) {
              recordState.value = RecordState.recordFinished;
            } else {
              recordState.value = RecordState.replaying;
            }
            log('$runtimeType,  ${DateTime.now()} replay completed: ${recordState.value}');
          }),
        )
        .catchError((e) {
      log('$runtimeType,  ${DateTime.now()} replay error: $e');
    });
  }

  Future<String> startRecord() async {
    if (folderPathObs.value.isEmpty) {
      return "NoPath";
    }
    recordState.value = RecordState.recording;
    log('$runtimeType, start record url: ${urlValueObs.value}, fileName  ');
    player.open(Media(urlValueObs.value));

    // final runCommandResult = await runCommandLine(
    //     url: urlValueObs.value, fileName: fileNameObs.value);
    // log('$runtimeType, runCommandResult: $runCommandResult ');
    // return runCommandResult;
    return "";
  }

  void selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      log('$runtimeType,${DateTime.now()} file path : $selectedDirectory');
      folderPathController.text = folderPathObs.value = selectedDirectory;
    }
  }

  // Future<String> _setDefaultDirectory() async {
  //   final directory = await getApplicationDocumentsDirectory();

  //   final path = "${directory.path}\\Videos";

  //   final ifDirectoryExist = await File(path).exists();

  //   if (!ifDirectoryExist) {
  //     var directory = await Directory(path).create(recursive: true);

  //     log('$runtimeType,  ${DateTime.now()} file path : ${directory.path} ');
  //   }
  //   return path;
  // }

  void stopRecord() async {
    log('$runtimeType,  ${DateTime.now()} stop record');
    // stop strea,
    player.stop();
    recordState.value = RecordState.waiting;
    final path = "${folderPathObs.value}\\${fileNameObs.value}.mp4";
    final cmd = 'del $path';

    // delete file
    log('$runtimeType,  ${DateTime.now()} stop record cmd:$cmd');

    try {
      // stop command
      await Process.run(
        'taskkill /IM "ffmpeg.exe" /F',
        [],
      ).then((result) {
        log('$runtimeType,  ${DateTime.now()} stop record exit code:${result.exitCode}');
        Process.run(
          runInShell: true,
          cmd,
          [],
        ).then((result1) => log(
            '$runtimeType,  ${DateTime.now()} stop record delete file exit code:${result1.exitCode}'));
      });
    } catch (e) {
      log('$runtimeType,  ${DateTime.now()} stop record error:${e.toString()}');
    }
    // reinit data
    _initData();
  }

  Future<bool> runCommandLine(
      {required String url, required String fileName}) async {
    recordState.value = RecordState.recording;

    Completer<bool> complete = Completer();

    final timeStamp = int.parse(selectionTimeObs.value) * recordMinutes;

    final path = folderPathObs.value;

    final command =
        'ffmpeg -i "$url" -reset_timestamps 1 -c copy -f segment -strftime 1 -segment_time $timeStamp -t $timeStamp $path\\$fileName.mp4';
    log('$runtimeType,  ${DateTime.now()} runCommandLine : $command ');

    await Process.run(
      command,
      [],
    ).then((result) {
      if (result.exitCode == 0) {
        complete.complete(true);
        recordState.value = RecordState.recordFinished;
        fileNameController.text = '';
        videoPathObs.value = "$path\\$fileName.mp4";

        Get.snackbar("", "Đã ghi video : ${videoPathObs.value}");
        player.stop().whenComplete(() =>
            player.open(Media("file:///${videoPathObs.value}"), play: false));

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

  Future<bool> exportData() async {
    Completer<bool> completer = Completer();
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
    file.writeAsString(videoInfo.toString()).then((e) {
      log('$runtimeType, Export data file path: ${e.path}');
      completer.complete(true);
    }).catchError((e) {
      log('$runtimeType, Export data error: ${e.toString()}');
      completer.complete(false);
    });
    return completer.future;
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
