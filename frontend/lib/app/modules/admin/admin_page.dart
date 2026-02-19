import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_controller.dart';
import 'package:get_storage/get_storage.dart';

class AdminPage extends StatelessWidget {
  AdminPage({super.key});
  final c = Get.put(AdminController());

  final rId = TextEditingController(text: "R2010");
  final rName = TextEditingController(text: "New Researcher");
  final rDept = TextEditingController(text: "CS");
  final rInterests = TextEditingController(text: "AI,NoSQL");

  final pId = TextEditingController(text: "P9001");
  final pTitle = TextEditingController(text: "New Project");
  final pSummary = TextEditingController(text: "Project added from Flutter");
  final pStatus = TextEditingController(text: "active");
  final pParticipants = TextEditingController(text: "R1001,R2010");

  final pubId = TextEditingController(text: "PUB9901");
  final pubTitle = TextEditingController(text: "New Paper");
  final pubYear = TextEditingController(text: "2026");
  final pubVenue = TextEditingController(text: "IEEE");
  final pubProject = TextEditingController(text: "P9001");
  final pubAuthors = TextEditingController(text: "R1001,R2010");

  final coA = TextEditingController(text: "R1001");
  final coB = TextEditingController(text: "R2010");
  final coCount = TextEditingController(text: "1");

  final sup = TextEditingController(text: "R1001");
  final stu = TextEditingController(text: "R2010");

  List<String> splitCsv(String s) =>
      s.split(",").map((x) => x.trim()).where((x) => x.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin / Data Management"),
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
          bottom: const TabBar(
            tabs: [
              Tab(text: "Researcher"),
              Tab(text: "Project"),
              Tab(text: "Publication"),
              Tab(text: "Relations"),
            ],
          ),
        ),
        body: Obx(
          () => Column(
            children: [
              if (c.loading.value) const LinearProgressIndicator(),
              if (c.msg.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(c.msg.value),
                ),
              Expanded(
                child: TabBarView(
                  children: [
                    // ===================== Researcher =====================
                    _formSection([
                      _tf("ID", rId),
                      _tf("Name", rName),
                      _tf("Department", rDept),
                      _tf("Interests (CSV)", rInterests),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => c.addResearcher(
                                id: rId.text.trim(),
                                name: rName.text.trim(),
                                dept: rDept.text.trim(),
                                interests: splitCsv(rInterests.text),
                                alsoNeo4j: true,
                              ),
                              child: const Text("Add"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => c.updateResearcher(
                                rId.text.trim(),
                                name: rName.text.trim(),
                                dept: rDept.text.trim(),
                                interests: splitCsv(rInterests.text),
                                alsoNeo4j: true, // update node fields too (optional)
                              ),
                              child: const Text("Update"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => c.deleteResearcher(rId.text.trim()),
                              child: const Text("Delete"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        " ",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ]),

                    // ===================== Project =====================
                    _formSection([
                      _tf("Project ID", pId),
                      _tf("Title", pTitle),
                      _tf("Summary", pSummary),
                      _tf("Status", pStatus),
                      _tf("Participants (CSV)", pParticipants),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => c.addProject(
                                id: pId.text.trim(),
                                title: pTitle.text.trim(),
                                summary: pSummary.text.trim(),
                                status: pStatus.text.trim(),
                                participants: splitCsv(pParticipants.text),
                              ),
                              child: const Text("Add"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => c.updateProject(
                                pId.text.trim(),
                                title: pTitle.text.trim(),
                                summary: pSummary.text.trim(),
                                status: pStatus.text.trim(),
                                participants: splitCsv(pParticipants.text),
                              ),
                              child: const Text("Update"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => c.deleteProject(pId.text.trim()),
                              child: const Text("Delete"),
                            ),
                          ),
                        ],
                      ),
                    ]),

                    // ===================== Publication =====================
                    _formSection([
                      _tf("Publication ID", pubId),
                      _tf("Title", pubTitle),
                      _tf("Year", pubYear),
                      _tf("Venue", pubVenue),
                      _tf("Project ID", pubProject),
                      _tf("Authors (CSV)", pubAuthors),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => c.addPublication(
                                id: pubId.text.trim(),
                                title: pubTitle.text.trim(),
                                year: int.tryParse(pubYear.text.trim()) ?? 2026,
                                venue: pubVenue.text.trim(),
                                projectId: pubProject.text.trim(),
                                authorIds: splitCsv(pubAuthors.text),
                              ),
                              child: const Text("Add"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => c.updatePublication(
                                pubId.text.trim(),
                                title: pubTitle.text.trim(),
                                year: int.tryParse(pubYear.text.trim()) ?? 2026,
                                venue: pubVenue.text.trim(),
                                projectId: pubProject.text.trim(),
                                authorIds: splitCsv(pubAuthors.text),
                              ),
                              child: const Text("Update"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => c.deletePublication(pubId.text.trim()),
                              child: const Text("Delete"),
                            ),
                          ),
                        ],
                      ),
                    ]),

                    // ===================== Relations =====================
                    _formSection([
                      const Text("CO_AUTHOR", style: TextStyle(fontWeight: FontWeight.bold)),
                      _tf("A", coA),
                      _tf("B", coB),
                      _tf("Count", coCount),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => c.addCoauthor(
                                a: coA.text.trim(),
                                b: coB.text.trim(),
                                count: int.tryParse(coCount.text.trim()) ?? 1,
                              ),
                              child: const Text("Add / Update"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => c.deleteCoauthor(
                                a: coA.text.trim(),
                                b: coB.text.trim(),
                              ),
                              child: const Text("Delete"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("SUPERVISES", style: TextStyle(fontWeight: FontWeight.bold)),
                      _tf("Supervisor", sup),
                      _tf("Student", stu),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => c.addSupervises(
                                supervisor: sup.text.trim(),
                                student: stu.text.trim(),
                              ),
                              child: const Text("Add"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => c.deleteSupervises(
                                supervisor: sup.text.trim(),
                                student: stu.text.trim(),
                              ),
                              child: const Text("Delete"),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formSection(List<Widget> children) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: children.expand((w) => [w, const SizedBox(height: 10)]).toList(),
    );
  }

  Widget _tf(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
