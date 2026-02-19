import 'package:get/get.dart';

import '../modules/home/home_page.dart';
import '../modules/profile/profile_page.dart';
import '../modules/projects/projects_page.dart';
import '../modules/analytics/analytics_page.dart';
import '../modules/graph/graph_page.dart';
import '../modules/admin/admin_page.dart';
import '../modules/login/login_page.dart'; // ✅ NEW

class AppPages {
  static final routes = [
    GetPage(name: "/", page: () => HomePage()),
    GetPage(name: "/login", page: () => LoginPage()), // ✅ NEW
    GetPage(name: "/profile", page: () => ProfilePage()),
    GetPage(name: "/projects", page: () => const ProjectsPage()),
    GetPage(name: "/analytics", page: () => AnalyticsPage()),
    GetPage(name: "/graph", page: () => const GraphPage()),
    GetPage(name: "/admin", page: () => AdminPage()),
  ];
}
