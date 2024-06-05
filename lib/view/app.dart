import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record_video/binding/my_home_page_binding.dart';
import 'my_home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/",
      getPages: [
        GetPage(
          name: "/",
          page: () => const MyHomePage(),
          binding: MyHomePageBinding(),
        )
      ],
    );
  }
}
