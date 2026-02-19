import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'analytics_controller.dart';

class AnalyticsPage extends StatelessWidget {
  AnalyticsPage({super.key});
  final c = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: Obx(() {
        if (c.loading.value) return const Center(child: CircularProgressIndicator());
        if (c.error.value.isNotEmpty) return Center(child: Text(c.error.value));

        final pair = c.topPair.value;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text("Most Collaborative Pair (Neo4j)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (pair != null)
                Text("${pair["researcherA"]} <-> ${pair["researcherB"]} | count = ${pair["collaborations"]}"),
              const Divider(height: 24),
              const Text("Top Researchers by Publications (MongoDB)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...c.topResearchers.map((x) => ListTile(
                    title: Text("Researcher: ${x["researcherId"]}"),
                    trailing: Text("${x["publications"]} pubs"),
                  )),
            ],
          ),
        );
      }),
    );
  }
}
