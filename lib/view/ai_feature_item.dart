import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:record_video/models/models.dart';

class AiFeatureItem extends StatelessWidget {
  final MultiChoiceItem aiFeature;
  final Function(MultiChoiceItem) onCheckChange;
  final Function(MultiChoiceItem) onClickExpand;
  final Function(MultiChoiceItem) onClickAddData;
  final Function(MultiChoiceItem, DataItem) onPressedDeleteData;

  const AiFeatureItem({
    super.key,
    required this.aiFeature,
    required this.onCheckChange,
    required this.onClickExpand,
    required this.onClickAddData,
    required this.onPressedDeleteData,
  });

  @override
  Widget build(BuildContext context) {
    log('$runtimeType, build: ${((aiFeature.data.length) / 3).ceil()}, ${aiFeature.data.length}');
    final heightCeil = ((aiFeature.data.length) / 3).ceil();
    return Container(
      height: 32 + ((aiFeature.isExpanded == true) ? (heightCeil * 42) : 0),
      color: Colors.grey.withOpacity(0.1),
      child: Column(
        children: [
          // header
          Container(
            color: Colors.grey.withOpacity(0.2),
            height: 32,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                          value: (aiFeature.isSelected),
                          onChanged: (value) {
                            onCheckChange.call(aiFeature);
                          }),
                      Text('${aiFeature.title}(${aiFeature.data.length})'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                  width: 32,
                  child: InkWell(
                    onTap: () {
                      // handle add new data for
                      onClickAddData.call(aiFeature);
                    },
                    child: const Icon(
                      Ionicons.add_outline,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
          // content show list data
          if (aiFeature.data.isNotEmpty == true) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              height: (heightCeil * 32),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 5,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 1,
                ),
                itemBuilder: (context, index) {
                  final dataItem = aiFeature.data[index];
                  return Container(
                    color: Colors.grey.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 40,
                    width: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${dataItem.value}'),
                        ),
                        SizedBox(
                          height: 32,
                          width: 32,
                          child: TextButton(
                            onPressed: () {
                              onPressedDeleteData.call(
                                aiFeature,
                                dataItem,
                              );
                            },
                            child: const Icon(
                              Ionicons.trash_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
                itemCount: aiFeature.data.length,
              ),
            )
          ]
        ],
      ),
      // child: ,
    );
  }
}
