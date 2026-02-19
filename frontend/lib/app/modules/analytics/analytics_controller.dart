import 'package:get/get.dart';
import '../../services/api_service.dart';

class AnalyticsController extends GetxController {
  final api = ApiService();

  final loading = false.obs;
  final error = "".obs;
  final topResearchers = <dynamic>[].obs;
  final topPair = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    loading.value = true;
    error.value = "";
    try {
      final a = await api.get("/analytics/top-researchers");
      final b = await api.get("/analytics/top-pair");
      topResearchers.assignAll(a ?? []);
      topPair.value = b;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
