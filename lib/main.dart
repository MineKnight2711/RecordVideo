import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:record_video/view/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const App());
}

