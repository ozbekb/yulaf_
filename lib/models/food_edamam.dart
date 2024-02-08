import 'dart:convert';
import 'package:http/http.dart' as http;

// Define a function to fetch food calorie information using the Edamam API
Future<void> fetchFoodCalories(String foodQuery) async {
  // Replace 'YOUR_API_KEY' with your actual Edamam API Key
  final apiKey = '0d87fb48';
  final endpoint = 'https://api.edamam.com/api/nutrition-data';
  final url =
      Uri.parse('$endpoint?app_id=YOUR_APP_ID&app_key=$apiKey&ingr=$foodQuery');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Parse and use the data as needed
      print(data);
    } else {
      // Handle error response
      print('Failed to fetch food calorie information: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network or other errors
    print('Error fetching food calorie information: $e');
  }
}
