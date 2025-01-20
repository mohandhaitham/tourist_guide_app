import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://simpleapplicablesolutions.pythonanywhere.com';

  Future<http.Response> submitTouristFacility(Map<String, dynamic> data) async {
    final String endpoint = '/tourist/guide/api/tourist/facility/p1/';
    final Uri url = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      // Print the response details for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('API request successful with status code 201');
      } else {
        print('API request failed with status code: ${response.statusCode}');
        // Save the full HTML response to a file

      }
      return response;
    } catch (e) {
      // Print any exceptions to the console
      print('Error making API request: $e');
      rethrow; // Rethrow the exception if needed
    }
  }

  Future<Map<String, dynamic>> fetchFormData() async {
    final response = await http.get(Uri.parse('https://simpleapplicablesolutions.pythonanywhere.com/tourist/guide/api/tourist/facility/form-data/'));
    // Print the response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to submit form: ${response.body}');
      throw Exception('Failed to load form data');
    }
  }
}
