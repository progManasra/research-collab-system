import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/api_service.dart';

class AdminController extends GetxController {
  final api = ApiService();
  final box = GetStorage();

  final loading = false.obs;
  final msg = "".obs;

  // ========================= Error Handling =========================
  bool _handleError(Object e, {String? onDuplicateMsg}) {
    final s = e.toString().toLowerCase();

    // Session expired / Unauthorized
    final is401 = s.contains("401") || s.contains("unauthorized");
    if (is401) {
      msg.value = "⚠️ Session expired. Please login again.";
      box.remove("sessionId");
      Get.offAllNamed("/login");
      return true;
    }

    // Duplicate key (Mongo)
    final isDuplicate = s.contains("11000") || s.contains("e11000") || s.contains("duplicate");
    if (isDuplicate) {
      msg.value = onDuplicateMsg ?? "⚠️ Duplicate data: cannot add (ID already exists).";
      return true;
    }

    return false; // not handled
  }

  // ========================= Helpers =========================
  Future<void> _run(
    String actionName,
    Future<void> Function() fn, {
    String? duplicateMsg,
  }) async {
    loading.value = true;
    msg.value = "";
    try {
      await fn();
      msg.value = "✅ $actionName";
    } catch (e) {
      final handled = _handleError(e, onDuplicateMsg: duplicateMsg);
      if (!handled) {
        msg.value = "❌ $actionName\n$e";
      }
    } finally {
      loading.value = false;
    }
  }

  // ========================= Researchers =========================
  Future<void> addResearcher({
    required String id,
    required String name,
    required String dept,
    required List<String> interests,
    bool alsoNeo4j = true,
  }) async {
    await _run(
      "Researcher added successfully.",
      () async {
        await api.post("/researchers", {
          "_id": id,
          "name": name,
          "department": dept,
          "interests": interests,
        });

        // Neo4j: upsert node after successful insert
        if (alsoNeo4j) {
          await api.post("/graph/researcher-node", {
            "id": id,
            "name": name,
            "department": dept,
          });
        }
      },
      duplicateMsg: "⚠️ Cannot add: Researcher ID already exists (duplicate). Use Update instead.",
    );
  }

  Future<void> updateResearcher(
    String id, {
    required String name,
    required String dept,
    required List<String> interests,
    bool alsoNeo4j = true,
  }) async {
    await _run("Researcher updated", () async {
      await api.put("/researchers/$id", {
        "name": name,
        "department": dept,
        "interests": interests,
      });

      if (alsoNeo4j) {
        await api.post("/graph/researcher-node", {
          "id": id,
          "name": name,
          "department": dept,
        });
      }
    });
  }

  Future<void> deleteResearcher(String id) async {
    await _run("Researcher deleted", () async {
      await api.delete("/researchers/$id");
      // NOTE: Neo4j node delete is optional. If you want it later, we can add /graph/researcher-node DELETE.
    });
  }

  // ========================= Projects =========================
  Future<void> addProject({
    required String id,
    required String title,
    required String summary,
    required String status,
    required List<String> participants, // list of researcherIds
  }) async {
    await _run(
      "Project added",
      () async {
        await api.post("/projects", {
          "_id": id,
          "title": title,
          "summary": summary,
          "status": status,
          "participants": participants
              .map((rid) => {"researcherId": rid, "role": "member"})
              .toList(),
          "publicationIds": [],
        });
      },
      duplicateMsg: "⚠️ Cannot add: Project ID already exists (duplicate). Use Update instead.",
    );
  }

  Future<void> updateProject(
    String id, {
    required String title,
    required String summary,
    required String status,
    required List<String> participants,
  }) async {
    await _run("Project updated", () async {
      await api.put("/projects/$id", {
        "title": title,
        "summary": summary,
        "status": status,
        "participants": participants
            .map((rid) => {"researcherId": rid, "role": "member"})
            .toList(),
      });
    });
  }

  Future<void> deleteProject(String id) async {
    await _run("Project deleted", () async {
      await api.delete("/projects/$id");
    });
  }

  // ========================= Publications =========================
  Future<void> addPublication({
    required String id,
    required String title,
    required int year,
    required String venue,
    required String projectId,
    required List<String> authorIds,
  }) async {
    await _run(
      "Publication added",
      () async {
        await api.post("/publications", {
          "_id": id,
          "title": title,
          "year": year,
          "venue": venue,
          "projectId": projectId,
          "authorIds": authorIds,
        });
      },
      duplicateMsg: "⚠️ Cannot add: Publication ID already exists (duplicate). Use Update instead.",
    );
  }

  Future<void> updatePublication(
    String id, {
    required String title,
    required int year,
    required String venue,
    required String projectId,
    required List<String> authorIds,
  }) async {
    await _run("Publication updated", () async {
      await api.put("/publications/$id", {
        "title": title,
        "year": year,
        "venue": venue,
        "projectId": projectId,
        "authorIds": authorIds,
      });
    });
  }

  Future<void> deletePublication(String id) async {
    await _run("Publication deleted", () async {
      await api.delete("/publications/$id");
    });
  }

  // ========================= Neo4j Relations =========================
  Future<void> addCoauthor({
    required String a,
    required String b,
    int count = 1,
  }) async {
    await _run("CO_AUTHOR added/updated", () async {
      await api.post("/graph/coauthor", {"a": a, "b": b, "count": count});
    });
  }

  Future<void> deleteCoauthor({
    required String a,
    required String b,
  }) async {
    await _run("CO_AUTHOR deleted", () async {
      await api.delete("/graph/coauthor?a=$a&b=$b");
    });
  }

  Future<void> addSupervises({
    required String supervisor,
    required String student,
  }) async {
    await _run("SUPERVISES added", () async {
      await api.post("/graph/supervises", {"supervisor": supervisor, "student": student});
    });
  }

  Future<void> deleteSupervises({
    required String supervisor,
    required String student,
  }) async {
    await _run("SUPERVISES deleted", () async {
      await api.delete("/graph/supervises?supervisor=$supervisor&student=$student");
    });
  }
}
