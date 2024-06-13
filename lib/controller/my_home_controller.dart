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
const defaultUrl =
    "rtsp://admin:Insen181@192.168.1.8:5541/cam/realmonitor?channel=1&subtype=1";

enum RecordState { waiting, recording, recordFinished, replaying }

class MyHomeController extends GetxController {
  late final Player player;

  late final VideoController playerController;
  final TextEditingController urlController = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController folderPathController = TextEditingController();

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
    _createListenerStream();
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
  }

  void _createListenerStream() {
    player.stream.log.listen((data) {
      final text = data.text;

      log('$runtimeType,  ${DateTime.now()} listenerStream: $text');
      log('$runtimeType,  ${DateTime.now()} listenerStream Record State: ${recordState.value}');

      if (text.contains('Container reported FPS')) {
        final fps =
            double.parse(text.substring('Container reported FPS: '.length));

        log('$runtimeType,  ${DateTime.now()} listenerStream: fps $fps');
        log('$runtimeType,  ${DateTime.now()} listenerStream: recordState ${recordState.value}');
        // if fps = 15 start command record video
        if (recordState.value == RecordState.waiting) {
          if (fps == defaultFps) {
            if (!_checkDirectory(folderPathObs.value)) {
              Get.snackbar(
                  "Lỗi", "Đường dẫn không hợp lệ vui lòng chọn lại đường dẫn");
              stopRecord();
              return;
            }
            runCommandLine(fileName: fileNameObs.value, url: urlValueObs.value);
          } else {
            stopRecord();
          }
        }
      }
    });
  }

  void _refreshData() {
    selectionTimeObs.value = '1';
    if (videoPathObs.value.isEmpty) {
      videoPathObs.value = folderPathObs.value = folderPathController.text = '';
    }
    fileNameObs.value = fileNameController.text = _formattedDate();
    if (urlValueObs.value.isEmpty) {
      urlValueObs.value = urlController.text = defaultUrl;
    }

    aiFeatureList.clear();
    aiFeatureList.value = _generateMultiChoiceItemList();
    log('$runtimeType,  ${DateTime.now()} _refreshData Record State: ${recordState.value}');
  }

  void _initData() {
    fileNameController.text = fileNameObs.value = _formattedDate();
    if (urlValueObs.value.isEmpty == true) {
      urlValueObs.value = urlController.text = defaultUrl;
    }
    aiFeatureList.value = _generateMultiChoiceItemList();
  }

  bool checkFeatureList() {
    return aiFeatureList.every((item) => item.checkEmptyData());
  }

  // handle value change
  void onTimeChange(String value) {
    selectionTimeObs.value = value;
    log('$runtimeType,  ${DateTime.now()} onTimeChange value: ${selectionTimeObs.value}');
  }

  void onUrlChange(String value) {
    urlValueObs.value = value;
    log('$runtimeType, onUrlChange value: ${urlValueObs.value}');
  }

  void onFileNameChange(String value) {
    value = value.replaceAll(' ', '_');

    fileNameController.text =
        fileNameObs.value = value.isNotEmpty ? value : _formattedDate();
    log('$runtimeType, onFileNameChange text controller value: ${fileNameController.text}');
    log('$runtimeType, onFileNameChange  obs value: ${fileNameObs.value}');
  }

  void replay() {
    recordState.value = RecordState.replaying;

    player
        .play()
        .whenComplete(
          () => player.stream.completed.listen((event) {
            if (event) {
              recordState.value = RecordState.recordFinished;
            }
            log('$runtimeType,  ${DateTime.now()} replay completed: ${recordState.value}');
          }),
        )
        .catchError((e) {
      log('$runtimeType,  ${DateTime.now()} replay error: $e');
    });
  }

  Future<String> startRecord() async {
    Completer<String> completer = Completer();
    if (folderPathObs.value.isEmpty) {
      return "NoPath";
    }
    log('$runtimeType,${DateTime.now()} startRecord url : ${urlValueObs.value}');
    player.open(Media(urlValueObs.value));
    final subcrition = player.stream.error.listen(null);
    subcrition.onData((event) {
      if (event.contains("Failed to") || event.contains("Cannot open file")) {
        completer.complete("InvalidUrl");
        stopRecord();
        log('$runtimeType,${DateTime.now()} startRecord : InvalidUrl');
      } else {
        completer.complete("");
        log('$runtimeType,${DateTime.now()} startRecord : $event');
      }
    });
    return completer.future;
  }

  Future<String> selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      // Check if the selectedDirectory contains any special Unicode characters or whitespace
      if (RegExp("[ \u00C0-\u1EF9]").hasMatch(selectedDirectory)) {
        log('$runtimeType,${DateTime.now()} Invalid directory path : $selectedDirectory');
        return "InvalidDirectory";
      }
      log('$runtimeType,${DateTime.now()} file path : $selectedDirectory');
      folderPathController.text = folderPathObs.value = selectedDirectory;
      return "Success";
    }
    return "NoSeletedDirectory";
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

  Future stopRecord() async {
    // stop stream,
    player.stop();
    //Change record state
    recordState.value = RecordState.waiting;

    final deleteFileCommand =
        "del ${folderPathObs.value}\\${fileNameObs.value}.mp4";

    const killFFmpegTaskCommand = 'taskkill /IM "ffmpeg.exe" /F';
    // delete file
    log('$runtimeType,  ${DateTime.now()} stopRecord cmd:$deleteFileCommand');

    try {
      // stop command
      await runProcess(killFFmpegTaskCommand).then((result) => log(
          '$runtimeType,  ${DateTime.now()} stopRecord kill process error:${result.stderr}'));
      await runProcess(deleteFileCommand, runInSheel: true).then((result) => log(
          '$runtimeType,  ${DateTime.now()} stopRecord kill process error:${result.stderr}'));
    } catch (e) {
      log('$runtimeType,  ${DateTime.now()} stop record uncatch exception:${e.toString()}');
    }
    // reinit data
    _initData();
  }

  Future<ProcessResult> runProcess(String command,
      {bool runInSheel = false}) async {
    return await Process.run(
      runInShell: runInSheel,
      command,
      [],
    );
  }

  void runCommandLine({required String url, required String fileName}) async {
    recordState.value = RecordState.recording;

    final timeStamp = int.parse(selectionTimeObs.value) * recordMinutes;

    final path = folderPathObs.value;

    final command =
        'ffmpeg -i "$url" -reset_timestamps 1 -c copy -f segment -strftime 1 -segment_time $timeStamp -t $timeStamp $path\\$fileName.mp4';
    log('$runtimeType,  ${DateTime.now()} runCommandLine : $command ');

    await runProcess(command).then((result) {
      if (result.exitCode == 0) {
        recordState.value = RecordState.recordFinished;
        fileNameController.text = '';
        videoPathObs.value = "$path\\$fileName.mp4";

        Get.snackbar("", "Đã ghi video : ${videoPathObs.value}");
        player.stop().whenComplete(() =>
            player.open(Media("file:///${videoPathObs.value}"), play: false));

        log('$runtimeType,  ${DateTime.now()} runCommandLine video path: ${videoPathObs.value}  ');
      } else {
        log('$runtimeType,  ${DateTime.now()} runCommandLine error: ${result.exitCode}  ');
      }
    });
  }

  bool _checkDirectory(String path) {
    final directory = Directory(path);
    return directory.existsSync();
  }

  String _formattedDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
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
      recordState.value = RecordState.waiting;
      refresh();
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
      title: 'Phát hiện con người',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: crowdDetect,
      title: 'Phát hiện đám đông',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: licensePlate,
      title: 'Biển số xe',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: faceDetect,
      title: 'Nhận diện khuôn mặt',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: fireDetect,
      title: 'Phát hiện cháy',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));
    result.add(MultiChoiceItem(
      id: fallDetect,
      title: 'Phát hiện người ngã',
      isSelected: false,
      isExpanded: true,
      data: [],
    ));

    return result;
  }
}
