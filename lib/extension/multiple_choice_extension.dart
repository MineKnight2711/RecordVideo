import '../models/multi_choice_item.dart';

extension MultipleChoiceModel on MultiChoiceItem {
  bool checkEmptyData() {
    return data.isEmpty;
  }
}
