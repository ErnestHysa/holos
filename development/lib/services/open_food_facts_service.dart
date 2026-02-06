import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeNutritionResult {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const BarcodeNutritionResult({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

/// Basic Open Food Facts barcode lookup.
class OpenFoodFactsService {
  Future<BarcodeNutritionResult?> lookupByBarcode(String barcode) async {
    final uri = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    if ((data['status'] as int?) != 1) return null;

    final product = (data['product'] as Map?)?.cast<String, dynamic>() ?? const {};
    final nutriments = (product['nutriments'] as Map?)?.cast<String, dynamic>() ?? const {};

    int _toInt(dynamic value) {
      if (value is num) return value.round();
      if (value is String) return num.tryParse(value)?.round() ?? 0;
      return 0;
    }

    return BarcodeNutritionResult(
      name: (product['product_name'] as String?)?.trim().isNotEmpty == true
          ? (product['product_name'] as String).trim()
          : 'Scanned food item',
      calories: _toInt(nutriments['energy-kcal_100g']),
      protein: _toInt(nutriments['proteins_100g']),
      carbs: _toInt(nutriments['carbohydrates_100g']),
      fat: _toInt(nutriments['fat_100g']),
    );
  }
}
