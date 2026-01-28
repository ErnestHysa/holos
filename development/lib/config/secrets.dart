/// Environment-based configuration for sensitive data
///
/// Usage:
/// 1. Create a .env file or set environment variables
/// 2. Run app with: flutter run --dart-define=EDAMAM_APP_ID=xxx --dart-define=EDAMAM_APP_KEY=yyy
/// 3. Or use a launch configuration in VS Code / Android Studio
///
/// Example launch.json:
/// {
///   "name": "Holos",
///   "request": "launch",
///   "type": "dart",
///   "args": [
///     "--dart-define=EDAMAM_APP_ID=your_app_id",
///     "--dart-define=EDAMAM_APP_KEY=your_app_key",
///     "--dart-define=GEMINI_API_KEY=your_gemini_key"
///   ]
/// }

class Secrets {
  /// Edamam Nutrition API credentials
  /// Get your keys at: https://developer.edamam.com/
  static const String edamamAppId = String.fromEnvironment('EDAMAM_APP_ID',
      defaultValue: 'YOUR_APP_ID');
  static const String edamamAppKey = String.fromEnvironment('EDAMAM_APP_KEY',
      defaultValue: 'YOUR_APP_KEY');

  /// Google Gemini AI API key
  /// Get your key at: https://ai.google.dev/gemini-api
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY',
      defaultValue: 'YOUR_GEMINI_API_KEY');

  /// Validates that all required secrets are configured
  static bool get isConfigured =>
      edamamAppId != 'YOUR_APP_ID' &&
      edamamAppKey != 'YOUR_APP_KEY' &&
      geminiApiKey != 'YOUR_GEMINI_API_KEY';

  /// Returns a list of missing secrets for debugging
  static List<String> get missingSecrets {
    final missing = <String>[];
    if (edamamAppId == 'YOUR_APP_ID') missing.add('EDAMAM_APP_ID');
    if (edamamAppKey == 'YOUR_APP_KEY') missing.add('EDAMAM_APP_KEY');
    if (geminiApiKey == 'YOUR_GEMINI_API_KEY') missing.add('GEMINI_API_KEY');
    return missing;
  }
}
