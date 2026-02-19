import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final c = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Integrated Profile"),
        actions: [
          IconButton(
            tooltip: "Refresh (Cache demo)",
            icon: const Icon(Icons.refresh),
            onPressed: c.fetchIntegrated,
          ),
        ],
      ),
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                c.error.value,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final r = c.researcher.value;
        if (r == null) return const Center(child: Text("No data"));

        final interests = (r["interests"] as List?) ?? const [];
        final projectsCount = c.projects.length;
        final pubsCount = c.publications.length;
        final collabCount = c.collaborators.length;
        final recentCount = c.recentQueries.length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== Header =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${r["name"]} (${r["_id"]})",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text("Department: ${r["department"]}"),
                    const SizedBox(height: 8),
                    Text("Interests: ${interests.join(", ")}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== Summary counters (nice for video) =====
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _miniStat("Mongo", "Projects", projectsCount),
                _miniStat("Mongo", "Publications", pubsCount),
                _miniStat("Neo4j", "Relations", collabCount),
                _miniStat("Redis", "Recent", recentCount),
              ],
            ),

            const SizedBox(height: 16),

            // ===== Neo4j Section =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Neo4j — Top Collaborators (Graph)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (c.collaborators.isEmpty)
                      const Text("No collaborators found.")
                    else
                      ...c.collaborators.take(6).map(
                            (x) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.account_tree),
                              title: Text("Collaborator: ${x["collaboratorId"]}"),
                              subtitle: Text("CO_AUTHOR count: ${x["times"]}"),
                            ),
                          ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: c.goToGraph,
                          icon: const Icon(Icons.hub),
                          label: const Text("View Graph"),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: c.fetchIntegrated,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh (Cache demo)"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== Redis Section =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Redis — Recent Queries (Cache/Session layer)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (c.recentQueries.isEmpty)
                      const Text("No recent queries")
                    else
                      ...c.recentQueries.take(6).map((q) => Text("• $q")),
                   
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== Mongo Section =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "MongoDB — Projects & Publications (Documents)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text("Projects: $projectsCount"),
                    Text("Publications: $pubsCount"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: c.goToProjects,
                          icon: const Icon(Icons.folder),
                          label: const Text("Open Projects"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: c.goToAnalytics,
                          icon: const Icon(Icons.analytics),
                          label: const Text("Open Analytics"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== Navigation quick actions =====
            OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text("Back"),
            ),
          ],
        );
      }),
    );
  }

  Widget _miniStat(String db, String label, int value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(db, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            "$value",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
