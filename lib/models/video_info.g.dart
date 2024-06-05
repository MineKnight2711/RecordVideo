// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoInfo _$VideoInfoFromJson(Map<String, dynamic> json) => VideoInfo(
      createdTime: (json['created_time'] as num?)?.toInt(),
      detections: (json['detections'] as List<dynamic>?)
          ?.map((e) => DetectionInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: (json['duration'] as num?)?.toInt(),
      videoName: json['video_name'] as String?,
    );

Map<String, dynamic> _$VideoInfoToJson(VideoInfo instance) => <String, dynamic>{
      'video_name': instance.videoName,
      'duration': instance.duration,
      'detections': instance.detections,
      'created_time': instance.createdTime,
    };
