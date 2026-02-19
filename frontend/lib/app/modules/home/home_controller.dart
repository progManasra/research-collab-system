import 'package:get/get.dart';
import '../../services/api_service.dart';

class HomeController extends GetxController {
  final api = ApiService();

  // ===== Researchers dropdown =====
  final researchers = <Map<String, dynamic>>[].obs;
  final selectedId = "R1001".obs;

  final loadingResearchers = false.obs;
  final error = "".obs;

  // ===== Redis Cache UI =====
  final cacheItems = <String>[].obs;
  final cacheTtl = 0.obs;
  final loadingCache = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadResearchers();
  }

  Future<void> loadResearchers() async {
    loadingResearchers.value = true;
    error.value = "";
    try {
      final data = await api.get("/researchers");

      if (data is List) {
        researchers.assignAll(
          data.map((e) => Map<String, dynamic>.from(e)).toList(),
        );

        // لو R1001 موجود خليه default، غير هيك اختار أول واحد
        if (researchers.isNotEmpty) {
          final hasR1001 = researchers.any((r) => r["_id"].toString() == "R1001");
          selectedId.value = hasR1001 ? "R1001" : researchers.first["_id"].toString();
        }
      } else {
        error.value = "Unexpected response from /researchers";
      }
    } catch (e) {
      error.value = "Failed to load researchers: $e";
    } finally {
      loadingResearchers.value = false;
    }
  }

  void setSelected(String id) {
    selectedId.value = id.trim();
  }

  void goToProfile() {
    error.value = "";
    if (selectedId.value.isEmpty) {
      error.value = "Please select a researcher";
      return;
    }
    Get.toNamed("/profile", arguments: {"id": selectedId.value});
  }

Future<void> loadCache() async {
  error.value = "";
  loadingCache.value = true;
  try {
    final res = await api.get("/cache/recent?limit=10");
    cacheItems.value = List<String>.from(res["items"] ?? []);
    cacheTtl.value =
        (res["ttl"] ?? 0) is int ? res["ttl"] : int.tryParse("${res["ttl"]}") ?? 0;
  } catch (e) {
    error.value = "Failed to load Redis cache: $e";
  } finally {
    loadingCache.value = false;
  }
}

}
