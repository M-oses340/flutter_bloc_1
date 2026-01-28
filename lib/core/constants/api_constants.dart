import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.get('BASE_URL', fallback: 'http://localhost');
  static String get loginEndpoint => "$baseUrl/auth/login/";
  static String get shopsEndpoint => dotenv.get('SHOPS_URL', fallback: '');
  static String get apiKey => dotenv.get('API_KEY', fallback: '');
}