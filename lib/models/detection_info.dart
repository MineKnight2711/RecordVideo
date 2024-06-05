
import 'package:equatable/equatable.dart';
import 'package:record_video/models/models.dart';

part 'detection_info.g.dart';
@JsonSerializable(ignoreUnannotated: true)
class DetectionInfo extends Equatable{

  @JsonKey(name: 'type')
  String? type;

  @JsonKey(name: 'events')
  List<String>? events;

  DetectionInfo({this.type,this.events,});

  factory DetectionInfo.fromJson(Map<String, dynamic> json) =>
      _$DetectionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DetectionInfoToJson(this);

  @override
  List<Object?> get props => [
    type,
    events,
  ];
}