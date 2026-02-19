import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final api = ApiService();
  late String researcherId;

  int depth = 1;
  final viewType = 'vis-graph-view';
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    researcherId = (Get.arguments?["id"] ?? "R1001") as String;

    final container = html.DivElement()
      ..id = 'vis-container'
      ..style.width = '100%'
      ..style.height = '1050px'
      ..style.border = '1px solid #ddd';

    // Register view factory once
    if (!_registered) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) => container);
      _registered = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => loadAndRender());
  }

  Future<void> loadAndRender() async {
    final data = await api.get("/graph/neighborhood/$researcherId?depth=$depth");

    // safer: JSON encode and pass into JS as string to avoid quoting issues
    final nodesJson = jsonEncode(data["nodes"]);
    final edgesJson = jsonEncode(data["edges"]);

    // Remove previous script if exists
    html.document.getElementById("vis-script")?.remove();

    final js = '''
      (function() {
        var container = document.getElementById('vis-container');
        if (!container) return;

        var nodes = new vis.DataSet($nodesJson);
        var edges = new vis.DataSet($edgesJson);

var options = {
  interaction: { hover: true, tooltipDelay: 80 },
  layout: { improvedLayout: true },
  physics: {
    enabled: true,
    solver: "barnesHut",
    barnesHut: {
      gravitationalConstant: -5000,
      springLength: 200,
      springConstant: 0.03,
      damping: 0.2,
      avoidOverlap: 1
    },
    stabilization: { iterations: 200 }
  },
  edges: { smooth: { type: "dynamic" } }
};

        // Clean container
        container.innerHTML = "";
        new vis.Network(container, { nodes: nodes, edges: edges }, options);
        network.on("click", function(params) {
  if (params.nodes.length) {
    alert("Node: " + params.nodes[0]);
  } else if (params.edges.length) {
    var e = edges.get(params.edges[0]);
    alert("Edge: " + e.from + " -> " + e.to + " | " + (e.title || ""));
  }
});

      })();
    ''';

    final script = html.ScriptElement()
      ..id = "vis-script"
      ..type = "text/javascript"
      ..text = js;

    html.document.body!.append(script);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Graph - $researcherId")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Depth: "),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: depth,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("1 (Neighbors)")),
                    DropdownMenuItem(value: 2, child: Text("2 (Neighbors of neighbors)")),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => depth = v);
                    loadAndRender();
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: loadAndRender,
                  child: const Text("Reload Graph"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Expanded(child: HtmlElementView(viewType: 'vis-graph-view')),
          ],
        ),
      ),
    );
  }
}
