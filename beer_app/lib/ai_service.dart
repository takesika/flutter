// lib/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static Future<String?> getImageQuery(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo-0613',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'functions': [
          {
            'name': 'get_image_url',
            'description': 'Returns the URL of an image from Unsplash',
            'parameters': {
              'type': 'object',
              'properties': {
                'query': {
                  'type': 'string',
                  'description': 'A query to search for',
                }
              },
              'required': ['query']
            }
          }
        ],
        'function_call': 'auto'
      }),
    );

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return json['choices'][0]['message']['function_call']['arguments']['query'];
  }

  static Future<String?> fetchImageUrl(String query) async {
    final accessKey = dotenv.env['UNSPLASH_ACCESS_KEY'];
    final response = await http.get(
      Uri.parse('https://api.unsplash.com/search/photos?query=$query&per_page=1'),
      headers: {
        'Authorization': 'Client-ID $accessKey'
      },
    );

    final json = jsonDecode(response.body);
    return json['results'][0]['urls']['regular'];
  }
}
