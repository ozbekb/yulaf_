import 'dart:convert';
import 'package:http/http.dart' as http;

//import 'package:http/http.dart' as http;
//import 'dart:convert';

class EdamamAPI {
  static const _appId = '0d87fb48';
  static const _appKey = '332a176b964e0a5c847ae401561d4bc4';
  static const String _baseURL =
      'https://api.edamam.com/api/food-database/v2/parser';

  static Map<String, dynamic> parseFoodData(Map<String, dynamic> foodData) {
    // Extracting relevant information
    String foodName = foodData['parsed'][0]['food']['label'];
    double calories = foodData['parsed'][0]['food']['nutrients']['ENERC_KCAL'];
    double protein = foodData['parsed'][0]['food']['nutrients']['PROCNT'];
    double fat = foodData['parsed'][0]['food']['nutrients']['FAT'];
    double carbs = foodData['parsed'][0]['food']['nutrients']['CHOCDF'];

    // Extracting serving size information
    String servingSizeLabel = '';
    double servingSizeWeight = 0.0;
    List<dynamic> measures = foodData['hints'][0]['measures'];
    for (var measure in measures) {
      if (measure['label'] == 'Serving') {
        servingSizeLabel = measure['label'];
        servingSizeWeight = measure['weight'];
        break;
      }
    }

    // Return parsed data
    return {
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'servingSizeLabel': servingSizeLabel,
      'servingSizeWeight': servingSizeWeight,
    };
  }

  static Future<Map<String, dynamic>> fetchFoodData(String query) async {
    final endpoint =
        '$_baseURL?app_id=$_appId&app_key=$_appKey&ingr=${Uri.encodeQueryComponent(query)}';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load food data');
    }
  }
}




/*// Define a function to fetch food calorie information using the Edamam API
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
*/