// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectionInfo _$DetectionInfoFromJson(Map<String, dynamic> json) =>
    DetectionInfo(
      type: json['type'] as String?,
      events:
          (json['events'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DetectionInfoToJson(DetectionInfo instance) =>
    <String, dynamic>{
      'type': instance.type,
      'events': instance.events,
    };
