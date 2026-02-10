import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/storage_service.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final String baseUrl = "http://13.51.196.227/customers/";
  final StorageService _storage = StorageService();

  // GET: Fetch Customers
  Future<List<Customer>> getCustomers(int shopId) async {
    final token = await _storage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl?shop_id=$shopId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = jsonDecode(response.body);
      if (decodedData['error'] == false) {
        final List<dynamic> customerList = decodedData['data'];
        return customerList.map((item) => Customer.fromJson(item)).toList();
      }
      throw Exception(decodedData['message']);
    }
    throw Exception('Failed to fetch customers');
  }

  // POST: Create Customer
  Future<Customer> createCustomer({
    required String name,
    required String phoneNumber,
    required int shopId,
  }) async {
    final token = await _storage.getToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": name,
        "phone_number": phoneNumber,
        "shop": shopId,
      }),
    );

    final Map<String, dynamic> decodedData = jsonDecode(response.body);

    if (response.statusCode == 201 || (response.statusCode == 200 && decodedData['error'] == false)) {
      // Return the newly created customer from the "data" field
      return Customer.fromJson(decodedData['data']);
    } else {
      throw Exception(decodedData['message'] ?? 'Failed to create customer');
    }
  }
  Future<Customer> getCustomerById(int customerId) async {
    final token = await _storage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl$customerId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = jsonDecode(response.body);


      return Customer.fromJson(decodedData);
    } else if (response.statusCode == 404) {
      throw Exception('Customer not found');
    } else {
      throw Exception('Failed to load customer details');
    }
  }
}