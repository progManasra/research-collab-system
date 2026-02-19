import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/api_service.dart';

class LoginController extends GetxController {
  final api = ApiService();
  final box = GetStorage();

  final loading = false.obs;
  final msg = "".obs;

  Future<void> login(String researcherId, String password) async {
    loading.value = true;
    msg.value = "";
    try {
      final res = await api.post("/auth/login", {
        "researcherId": researcherId.trim(),
        "password": password.trim(),
      });

      box.write("sessionId", res["sessionId"]);
      box.write("researcherId", res["researcherId"]);

      msg.value = "✅ Logged in. TTL: ${res["expiresInSec"]}s";
Get.offAllNamed("/");
    } catch (e) {
      msg.value = "❌ Login failed\n$e";
    } finally {
      loading.value = false;
    }
  }

  void logout() {
    box.remove("sessionId");
    Get.offAllNamed("/login");
  }
}
