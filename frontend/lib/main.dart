import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final hasSession = box.read("sessionId") != null;

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
      title: 'Research Collaboration System',
      initialRoute: hasSession ? "/" : "/login",
      getPages: AppPages.routes,
    );
  }

}
