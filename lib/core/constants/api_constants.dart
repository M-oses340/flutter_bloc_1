import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl = "http://13.51.196.227/";

  // ✅ Added the auth path
  static String changePassword = "${baseUrl}auth/v1/auth/change-password/";

  static String get apiKey => dotenv.get('API_KEY', fallback: '');
}