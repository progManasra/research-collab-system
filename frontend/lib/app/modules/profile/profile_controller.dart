import 'package:get/get.dart';
import '../../services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService api = ApiService();

  final loading = false.obs;
  final error = "".obs;

  final researcher = Rxn<Map<String, dynamic>>();
  final projects = <Map<String, dynamic>>[].obs;
  final publications = <Map<String, dynamic>>[].obs;
  final collaborators = <Map<String, dynamic>>[].obs;
  final recentQueries = <String>[].obs;

  late final String id;

  @override
  void onInit() {
    super.onInit();
    final argId = Get.arguments?["id"];
    id = (argId is String) ? argId : "";
    if (id.isEmpty) {
      error.value = "Missing researcher id.";
      return;
    }
    fetchIntegrated();
  }

  Future<void> fetchIntegrated() async {
    loading.value = true;
    error.value = "";
    try {
      final data = await api.get("/researchers/$id/profile-integrated");

      researcher.value = (data["researcher"] as Map?)?.cast<String, dynamic>();

      // ✅ Force safe types (List<Map>)
      final p = (data["projects"] as List?) ?? [];
      projects.assignAll(p.map((e) => (e as Map).cast<String, dynamic>()).toList());

      final pub = (data["publications"] as List?) ?? [];
      publications.assignAll(pub.map((e) => (e as Map).cast<String, dynamic>()).toList());

      final col = (data["collaborators"] as List?) ?? [];
      collaborators.assignAll(col.map((e) => (e as Map).cast<String, dynamic>()).toList());

      final rq = (data["recentQueries"] as List?) ?? [];
      recentQueries.assignAll(rq.map((e) => e.toString()).toList());
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void goToProjects() {
    // ✅ pass normal Lists (NOT RxList)
    Get.toNamed("/projects", arguments: {
      "projects": projects.toList(),
      "publications": publications.toList(),
      "researcherId": id,
    });
  }

  void goToAnalytics() => Get.toNamed("/analytics");
  void goToGraph() => Get.toNamed("/graph", arguments: {"id": id});
}
