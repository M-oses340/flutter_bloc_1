import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';

class ExpenseRepository {
  final StorageService _storage = StorageService();

  String get _cleanBaseUrl {
    String url = ApiConstants.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': ApiConstants.apiKey,
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Expense>> fetchExpenses(int shopId) async {
    // 1. Prepare Date Parameters (Format: YYYY-MM-DD)
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final String startDate = firstDayOfMonth.toString().split(' ').first;
    final String endDate = now.toString().split(' ').first;

    // 2. Build the precise URL required by your API
    final String url = "$_cleanBaseUrl/expenses/"
        "?shop_id=$shopId"
        "&start_date=$startDate"
        "&end_date=$endDate";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );


      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Adjust 'data' to 'results' if your API uses a different key
        final List data = body['data'] ?? body['results'] ?? [];
        return data.map((e) => Expense.fromJson(e)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // GET BY ID (Fixes your 'method not defined' error)
  Future<Expense> fetchExpenseById(int id) async {
    final response = await http.get(
      Uri.parse("$_cleanBaseUrl/expenses/$id/"),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Expense.fromJson(body['data'] ?? body);
    }
    throw Exception("Expense not found");
  }

  // POST (Fixes your 'Map vs Expense' type error)
  Future<Expense> addExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse("$_cleanBaseUrl/expenses/"),
      headers: await _getHeaders(),
      body: jsonEncode(expense.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Expense.fromJson(body['data'] ?? body);
    }
    throw Exception("Failed to create expense");
  }

  // DELETE
  Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse("$_cleanBaseUrl/expenses/$id/"),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception("Delete failed");
    }
  }
}