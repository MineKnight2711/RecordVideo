import 'package:record_video/models/models.dart';

class MultiChoiceItem {
  String? id;
  String? title;
  bool? isSelected;
  bool? isExpanded;
  List<DataItem> data;

  MultiChoiceItem({
    this.id,
    required this.data,
    this.title,
    this.isSelected,
    this.isExpanded,
  });
}
