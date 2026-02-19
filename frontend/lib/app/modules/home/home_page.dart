import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
final c = Get.put(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Research Collaboration System"),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: () {
              final box = GetStorage();
              box.remove("sessionId");
              Get.offAllNamed("/login");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Select Researcher (ID + Name)", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            // ===== Researchers Dropdown =====
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (c.loadingResearchers.value) const LinearProgressIndicator(),

                  DropdownButtonFormField<String>(
                    value: c.selectedId.value.isEmpty ? null : c.selectedId.value,
                    items: c.researchers.map((r) {
                      final id = r["_id"].toString();
                      final name = (r["name"] ?? "").toString();
                      return DropdownMenuItem(
                        value: id,
                        child: Text("$id - $name"),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) c.setSelected(v);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Choose researcher",
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          onPressed: c.loadResearchers,
                          label: const Text("Refresh List"),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),

            const SizedBox(height: 12),
            Obx(() => Text(c.error.value, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.person_search),
              onPressed: c.goToProfile,
              label: const Text("Load Integrated Profile"),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Get.toNamed("/admin"),
              label: const Text("Admin / Data Management"),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.hub),
              onPressed: () => Get.toNamed("/graph"),
              label: const Text("Graph View"),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.analytics),
              onPressed: () => Get.toNamed("/analytics"),
              label: const Text("Analytics"),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.folder),
              onPressed: () => Get.toNamed("/projects"),
              label: const Text("Projects"),
            ),

            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),

           // ===== Redis Cache UI =====
OutlinedButton.icon(
  icon: const Icon(Icons.bolt),
  onPressed: c.loadCache,
  label: const Text("Show Redis Cache (Recent Queries + TTL)"),
),
const SizedBox(height: 10),

Obx(() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Redis TTL: ${c.cacheTtl.value}s",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Recent Queries (Redis List):"),
          const SizedBox(height: 6),
          if (c.cacheItems.isEmpty)
            const Text(
              "No recent queries.",
              style: TextStyle(color: Colors.black54),
            )
          else
            ...c.cacheItems.map((x) => Text("• $x")),
        ],
      ),
    ),
  );
}),


          ],
        ),
      ),
    );
  }
}
