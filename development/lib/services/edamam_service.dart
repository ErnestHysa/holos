import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';

/// Edamam Nutrition API Service
/// Used for: Food database, barcode lookup, recipe search
/// Documentation: https://developer.edamam.com/
class EdamamService {
  static const String appId = Secrets.edamamAppId;
  static const String appKey = Secrets.edamamAppKey;

  /// Search for food by name
  static Future<Map<String, dynamic>> searchFood(String query) async {
    final uri = Uri.https('api.edamam.com', '/api/food-database/v2/parser', {
      'app_id': appId,
      'app_key': appKey,
      'ingr': query,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search food: ${response.statusCode}');
    }
  }

  /// Lookup food by barcode
  static Future<Map<String, dynamic>> lookupBarcode(String barcode) async {
    final uri = Uri.https('api.edamam.com', '/api/food-database/v2/parser', {
      'app_id': appId,
      'app_key': appKey,
      'upc': barcode,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to lookup barcode: ${response.statusCode}');
    }
  }

  /// Get nutrition info for a food item
  static Future<Map<String, dynamic>> getNutrition(String foodId) async {
    final uri = Uri.https('api.edamam.com', '/api/food-database/v2/nutrients', {
      'app_id': appId,
      'app_key': appKey,
      'upc': foodId, // Use upc parameter for barcode/foodId lookup
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get nutrition: ${response.statusCode}');
    }
  }

  /// Search recipes
  static Future<Map<String, dynamic>> searchRecipes({
    required String query,
    int? from = 0,
    int? to = 10,
  }) async {
    final uri = Uri.https('api.edamam.com', '/api/recipes/v2', {
      'app_id': appId,
      'app_key': appKey,
      'type': 'public',
      'q': query,
      'from': from.toString(),
      'to': to.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search recipes: ${response.statusCode}');
    }
  }
}
