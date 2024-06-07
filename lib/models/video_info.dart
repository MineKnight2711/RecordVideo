import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:record_video/models/models.dart';
part 'video_info.g.dart';

@JsonSerializable(ignoreUnannotated: true)
// ignore: must_be_immutable
class VideoInfo extends Equatable {
  @JsonKey(name: 'video_name')
  String? videoName;

  @JsonKey(name: 'duration')
  int? duration;

  @JsonKey(name: 'detections')
  List<DetectionInfo>? detections;

  @JsonKey(name: 'created_time')
  int? createdTime;

  VideoInfo({
    this.createdTime,
    this.detections,
    this.duration,
    this.videoName,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) =>
      _$VideoInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoInfoToJson(this);

  @override
  List<Object?> get props => [
        createdTime,
        detections,
        duration,
        videoName,
      ];

  @override
  String toString() {
    return jsonEncode(this);
  }
}
