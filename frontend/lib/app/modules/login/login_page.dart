import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final c = Get.put(LoginController());
  final idCtrl = TextEditingController(text: "R1001");
  final pwCtrl = TextEditingController(text: "1234");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (c.loading.value) const LinearProgressIndicator(),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(
                labelText: "Researcher ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pwCtrl,
              decoration: const InputDecoration(
                labelText: "Password (prototype)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => c.login(idCtrl.text, pwCtrl.text),
              child: const Text("Login"),
            ),
            const SizedBox(height: 12),
            Text(c.msg.value),
          ],
        ),
      )),
    );
  }
}
