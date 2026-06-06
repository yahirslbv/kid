import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  static const _geminiApiKeyFromBuild =
      String.fromEnvironment('GEMINI_API_KEY');

  static String get geminiApiKey {
    if (_geminiApiKeyFromBuild.isNotEmpty) {
      return _geminiApiKeyFromBuild;
    }

    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }
}
