import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final List projects = args["projects"] ?? [];
    final List pubs = args["publications"] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Projects & Publications")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Projects", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...projects.map((p) => ListTile(
                  title: Text("${p["_id"]}: ${p["title"]}"),
                  subtitle: Text("Status: ${p["status"]}"),
                )),
            const Divider(height: 24),
            const Text("Publications", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...pubs.map((pub) => ListTile(
                  title: Text("${pub["_id"]}: ${pub["title"]}"),
                  subtitle: Text("Year: ${pub["year"]} | Project: ${pub["projectId"]}"),
                )),
          ],
        ),
      ),
    );
  }
}
