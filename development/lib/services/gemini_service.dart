import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';

/// Gemini API Service for AI meal suggestions
/// Used for: Generate personalized meal recommendations based on goals, activity, health data
/// Documentation: https://ai.google.dev/gemini-api
class GeminiService {
  static const String _apiKey = Secrets.geminiApiKey;
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

  /// Generate meal suggestion
  /// Returns: JSON with meal name, description, recipe, macros
  static Future<Map<String, dynamic>> generateMealSuggestion({
    required Map<String, dynamic> userProfile,
    required Map<String, dynamic> dailyStats,
    required Map<String, dynamic> healthData,
  }) async {
    // Build prompt from context
    final prompt = '''
Generate a meal suggestion for ${userProfile['displayName'] ?? 'user'}.

User Context:
- Primary Goal: ${userProfile['primaryGoal']}
- Dietary Preferences: ${userProfile['dietaryPreferences']?.join(', ') ?? 'none'}
- Allergens: ${userProfile['allergens']?.join(', ') ?? 'none'}

Today's Stats:
- Calories Consumed: ${dailyStats['caloriesConsumed'] ?? 0} kcal
- Calories Target: ${dailyStats['caloriesTarget'] ?? 2000} kcal
- Protein Remaining: ${dailyStats['proteinRemaining'] ?? 60}g
- Carbs Remaining: ${dailyStats['carbsRemaining'] ?? 120}g
- Fat Remaining: ${dailyStats['fatRemaining'] ?? 30}g

Health Data:
- Sleep Duration: ${healthData['sleepDuration'] ?? 7.5}h
- Sleep Quality: ${healthData['sleepQuality'] ?? 85}/100
- Steps Today: ${healthData['steps'] ?? 8500}
- Activity Level: ${healthData['activityLevel'] ?? 'moderate'}
- Stress Level: ${healthData['stressLevel'] ?? 'moderate'}

Requirements:
- Generate a meal that fits remaining macros
- Consider dietary preferences and allergens
- If sleep was poor (<70), suggest sleep-supporting foods
- If activity was high (>10000 steps), suggest recovery meal
- If stress was high (>70), suggest stress-reducing foods
- Time of day: Consider breakfast, lunch, or dinner suggestion

Return JSON with:
{
  "mealName": "Name of meal",
  "description": "Brief description of meal (1-2 sentences)",
  "recipe": "Full recipe with ingredients and cooking instructions",
  "macros": {
    "calories": 700,
    "protein": 40,
    "carbs": 35,
    "fat": 30
  },
  "emoji": "Appropriate emoji for meal"
}
''';

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 500,
        },
      }),
    );

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);

        // Check if response has expected structure
        if (responseData['candidates'] == null ||
            responseData['candidates'].isEmpty ||
            responseData['candidates'][0]['content'] == null ||
            responseData['candidates'][0]['content']['parts'] == null ||
            responseData['candidates'][0]['content']['parts'].isEmpty) {
          return _getFallbackMealSuggestion('Invalid response structure from AI');
        }

        final content = responseData['candidates'][0]['content']['parts'][0]['text'];

        // Parse JSON from response
        try {
          final jsonContent = json.decode(content.trim());
          return jsonContent;
        } on FormatException {
          // AI returned non-JSON text, try to extract JSON or use fallback
          return _extractJsonFromText(content) ?? _getFallbackMealSuggestion('AI returned non-JSON response');
        }
      } on FormatException catch (e) {
        return _getFallbackMealSuggestion('JSON parsing error: ${e.message}');
      } catch (e) {
        return _getFallbackMealSuggestion('Response parsing error: $e');
      }
    } else if (response.statusCode == 429) {
      throw Exception('API rate limit exceeded. Please try again later.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key. Please check your Gemini API configuration.');
    } else {
      throw Exception('Failed to generate meal suggestion: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  /// Fallback meal suggestion when AI fails
  static Map<String, dynamic> _getFallbackMealSuggestion(String reason) {
    return {
      'mealName': 'Healthy Balanced Meal',
      'description': 'A nutritious meal based on your health goals. ($reason)',
      'recipe': 'Combine lean protein with vegetables and whole grains.',
      'macros': {'calories': 500, 'protein': 30, 'carbs': 45, 'fat': 18},
      'emoji': '🍽️',
      'fallback': true,
      'reason': reason,
    };
  }

  /// Extract JSON from text that may contain markdown code blocks
  static Map<String, dynamic>? _extractJsonFromText(String text) {
    // Try to find JSON block in markdown format
    final jsonBlockRegex = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonBlockRegex.firstMatch(text);

    if (match != null) {
      try {
        return json.decode(match.group(1)!);
      } catch (e) {
        return null;
      }
    }

    // Try to find object between { and }
    final objectRegex = RegExp(r'\{[\s\S]*\}');
    final objectMatch = objectRegex.firstMatch(text);

    if (objectMatch != null) {
      try {
        return json.decode(objectMatch.group(0)!);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Generate recipe from meal name
  static Future<Map<String, dynamic>> generateRecipe({
    required String mealName,
    required List<String> dietaryRestrictions,
  }) async {
    final restrictions = dietaryRestrictions.join(', ');
    final prompt = '''
Generate a detailed recipe for: $mealName

Dietary Restrictions: $restrictions

Requirements:
- Include ingredients list with quantities
- Include step-by-step cooking instructions
- Include cooking time
- Include serving size
- Ensure recipe is healthy and balanced

Return JSON with:
{
  "recipeName": "$mealName",
  "ingredients": ["ingredient 1 (quantity)", "ingredient 2 (quantity)", ...],
  "instructions": ["step 1", "step 2", ...],
  "cookingTime": "X minutes",
  "servings": Y,
  "macros": {
    "calories": X,
    "protein": Y,
    "carbs": Z,
    "fat": W
  }
}
''';

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 800,
        },
      }),
    );

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);

        // Check if response has expected structure
        if (responseData['candidates'] == null ||
            responseData['candidates'].isEmpty ||
            responseData['candidates'][0]['content'] == null ||
            responseData['candidates'][0]['content']['parts'] == null ||
            responseData['candidates'][0]['content']['parts'].isEmpty) {
          return _getFallbackRecipe(mealName, 'Invalid response structure from AI');
        }

        final content = responseData['candidates'][0]['content']['parts'][0]['text'];

        // Parse JSON from response
        try {
          final jsonContent = json.decode(content.trim());
          return jsonContent;
        } on FormatException {
          // AI returned non-JSON text, try to extract JSON or use fallback
          return _extractJsonFromText(content) ?? _getFallbackRecipe(mealName, 'AI returned non-JSON response');
        }
      } on FormatException catch (e) {
        return _getFallbackRecipe(mealName, 'JSON parsing error: ${e.message}');
      } catch (e) {
        return _getFallbackRecipe(mealName, 'Response parsing error: $e');
      }
    } else if (response.statusCode == 429) {
      throw Exception('API rate limit exceeded. Please try again later.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key. Please check your Gemini API configuration.');
    } else {
      throw Exception('Failed to generate recipe: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  /// Fallback recipe when AI fails
  static Map<String, dynamic> _getFallbackRecipe(String mealName, String reason) {
    return {
      'recipeName': mealName,
      'ingredients': ['Adjust based on preferences'],
      'instructions': ['Cook as usual'],
      'cookingTime': '20-30 min',
      'servings': 1,
      'macros': {'calories': 500, 'protein': 25, 'carbs': 50, 'fat': 20},
      'fallback': true,
      'reason': reason,
    };
  }
}
