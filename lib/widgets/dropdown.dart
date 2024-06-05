import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';


class DropDown extends StatefulWidget {

  final List<String> items;
  final String selectedValue;
  final Function(String) onChanged;
  final String title;
  const DropDown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.title,
  });

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  String selectedValue = '';
  @override
  void initState() {
    setState(() {
      selectedValue =  widget.selectedValue;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      decoration: BoxDecoration(
        // color: Colors.red,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      height: 48,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint:  Row(
            children: [
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: widget.items
              .map(
                (String item) =>
                DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
          )
              .toList(),
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue =  value ?? '';
            });
            widget.onChanged.call(value ?? '');
          },
        ),
      ),
    );
  }
}

//
// class DropDown extends StatelessWidget {
//
//   final List<String> items;
//   final String selectedValue;
//   final Function(String) onChanged;
//   final String title;
//   const DropDown({
//     super.key,
//     required this.items,
//     required this.selectedValue,
//   required this.onChanged,
//   required this.title,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 10,
//       decoration: BoxDecoration(
//         // color: Colors.red,
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.black.withOpacity(0.2),
//             width: 1.0,
//           ),
//         ),
//       ),
//       height: 48,
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton2<String>(
//           isExpanded: true,
//           hint:  Row(
//             children: [
//               const SizedBox(
//                 width: 4,
//               ),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           items: items
//               .map(
//                 (String item) =>
//                 DropdownMenuItem<String>(
//                   value: item,
//                   child: Text(
//                     item,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//           )
//               .toList(),
//           value: selectedValue,
//           onChanged: (value) {
//             onChanged.call(value ?? '');
//           },
//         ),
//       ),
//     );
//   }
// }
