import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Icon icon;
  final String title, message;
  final VoidCallback? onOkPressed;
  final bool showCancelButton;
  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.onOkPressed,
    this.showCancelButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        height: 230,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(title),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                message,
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: onOkPressed ?? () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: showCancelButton,
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Huỷ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
