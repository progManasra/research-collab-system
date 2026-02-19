import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

class ApiService {
  // Android Emulator: http://10.0.2.2:3000
  // Windows Desktop: http://localhost:3000
  // static const String baseUrl = "http://10.0.2.2:3000";
  static const String baseUrl = "http://localhost:3000";

  final _box = GetStorage();

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
  ))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _box.read("sessionId");
          if (token != null && token.toString().isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
  final status = e.response?.statusCode;
  final data = e.response?.data;

  // استخراج رسالة الخطأ من الباكند لو موجودة
  final backendError =
      (data is Map && data["error"] != null) ? "${data["error"]}" : "";

  final isSessionExpired =
      status == 401 ||
      backendError.toLowerCase().contains("session expired") ||
      backendError.toLowerCase().contains("invalid");

  // لو session انتهت → امسح token وارجع login مع رسالة
  if (isSessionExpired) {
    _box.remove("sessionId");

    // منع loop: لو احنا أصلاً على login ما نعيد تحويل
    if (Get.currentRoute != "/login") {
      Get.snackbar(
        "Session Expired",
        "Your session has ended. Please login again.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      Get.offAllNamed("/login");
    }
  }

  // خليك محافظ على طباعة error بشكل واضح زي ما كنت عامل
  e = e.copyWith(
    message: "HTTP ${status ?? "?"} ${e.message}\n${data ?? ""}",
  );

  handler.next(e);
},

      ),
    );

  Future<dynamic> get(String path) async {
    final res = await _dio.get(path);
    return res.data;
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _dio.post(path, data: body);
    return res.data;
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await _dio.put(path, data: body);
    return res.data;
  }

  Future<dynamic> delete(String path) async {
    final res = await _dio.delete(path);
    return res.data;
  }
}
