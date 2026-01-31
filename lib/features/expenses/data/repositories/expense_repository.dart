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

  // GET ALL
  Future<List<Expense>> fetchExpenses(int shopId) async {
    final response = await http.get(
      Uri.parse("$_cleanBaseUrl/expenses/?shop=$shopId"),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => Expense.fromJson(e)).toList();
    }
    throw Exception("Failed to load expenses");
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