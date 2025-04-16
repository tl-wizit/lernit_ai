import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpenAIService {
  static const _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final _storage = const FlutterSecureStorage();

  Future<String?> getApiKey() async {
    return await _storage.read(key: 'openai_api_key');
  }

  Future<String?> generateScenarioWithAI({
    required String prompt,
    String model = 'gpt-4.1-nano-2025-04-14',
    int maxTokens = 2048,
    double temperature = 0.7,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null) throw Exception('OpenAI API key not set');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are an expert instructional designer. When given a prompt, always generate a JSON object for a scenario with this structure:\n{\n  "title": "string (non-empty)",\n  "description": "string (non-empty)",\n  "scenes": [\n    {\n      "title": "string (non-empty)",\n      "description": "string (non-empty)",\n      "problems": [\n        {\n          "title": "string (non-empty)",\n          "description": "string (non-empty)",\n          "resolution": "string (non-empty)"\n        }\n      ]\n    }\n  ]\n}\nEach field must be non-empty. Output only valid JSON for a scenario as described.'
        },
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': maxTokens,
      'temperature': temperature,
    });
    final response =
        await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
    if (response.statusCode == 200) {
      // Decode as UTF-8 before parsing JSON to handle accents and special characters
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI error: ${response.body}');
    }
  }
}
