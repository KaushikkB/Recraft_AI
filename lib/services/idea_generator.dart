import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/idea_model.dart';

class IdeaGeneratorService {
  // OpenRouter Configuration for Mistral 7B
  static const String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _apiKey = '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';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      if (_apiKey.isEmpty || _apiKey.contains('your_openrouter_key')) {
        throw Exception('Please set your OpenRouter API key');
      }
      _isInitialized = true;
      print('✅ Mistral 7B Idea Generator initialized');
    } catch (e) {
      print('❌ Mistral service initialization failed: $e');
      rethrow;
    }
  }

  Future<List<IdeaModel>> generateIdeas(String objectName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('🤖 Calling Mistral 7B via OpenRouter for: $objectName');

      final response = await http.post(
        Uri.parse(_openRouterUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://recraftai.app',
          'X-Title': 'ReCraft AI',
        },
        body: json.encode({
          'model': 'mistralai/mistral-7b-instruct:free', // Mistral 7B model
          'messages': [
            {
              'role': 'system',
              'content': 'You are a creative DIY expert specializing in upcycling and sustainability. Generate exactly 3 creative upcycling ideas in valid JSON format. Always return valid JSON.'
            },
            {
              'role': 'user',
              'content': _buildPrompt(objectName)
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.8,
        }),
      ).timeout(const Duration(seconds: 60));

      print('📡 Mistral 7B response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        print('✅ Received Mistral 7B response');
        return _parseAIResponse(content, objectName);
      } else {
        throw Exception('Mistral 7B API error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Mistral 7B API call failed: $e');
      rethrow;
    }
  }

  String _buildPrompt(String objectName) {
    return '''
Generate exactly 3 creative DIY upcycling ideas for a $objectName.

Return ONLY a valid JSON array in this exact format:

[
  {
    "title": "Creative Project Name 1",
    "description": "Brief description of what the project creates",
    "materials": ["material1", "material2", "material3", "material4"],
    "steps": ["Step 1 instruction", "Step 2 instruction", "Step 3 instruction", "Step 4 instruction"]
  },
  {
    "title": "Creative Project Name 2", 
    "description": "Brief description of what the project creates",
    "materials": ["material1", "material2", "material3", "material4"],
    "steps": ["Step 1 instruction", "Step 2 instruction", "Step 3 instruction", "Step 4 instruction"]
  },
  {
    "title": "Creative Project Name 3",
    "description": "Brief description of what the project creates", 
    "materials": ["material1", "material2", "material3", "material4"],
    "steps": ["Step 1 instruction", "Step 2 instruction", "Step 3 instruction", "Step 4 instruction"]
  }
]

Requirements:
- Make ideas practical and beginner-friendly
- Use eco-friendly materials
- Ensure steps are clear and actionable
- Focus on creative transformation
- Return ONLY the JSON array, no other text
''';
  }

  List<IdeaModel> _parseAIResponse(String generatedText, String objectName) {
    try {
      print('🔍 Parsing Mistral 7B response...');

      // Clean the response - remove markdown code blocks
      String cleanText = generatedText.replaceAll('```json', '').replaceAll('```', '').trim();

      // Extract JSON from response
      final jsonMatch = RegExp(r'\[\s*\{[\s\S]*\}\s*\]').firstMatch(cleanText);
      if (jsonMatch == null) {
        throw Exception('Mistral 7B did not return valid JSON format. Received: $cleanText');
      }

      final jsonStr = jsonMatch.group(0);
      final ideasJson = json.decode(jsonStr!) as List;

      final ideas = ideasJson.map((ideaJson) {
        return IdeaModel(
          title: ideaJson['title']?.toString().trim() ?? 'Creative Upcycling Idea',
          description: ideaJson['description']?.toString().trim() ?? 'Transform your $objectName creatively',
          materials: List<String>.from(ideaJson['materials']?.map((m) => m.toString().trim()) ?? []),
          steps: List<String>.from(ideaJson['steps']?.map((s) => s.toString().trim()) ?? []),
          timestamp: DateTime.now(),
        );
      }).toList();

      print('✅ Successfully parsed ${ideas.length} Mistral-generated ideas');
      return ideas;
    } catch (e) {
      print('❌ Mistral response parsing failed: $e');
      throw Exception('Failed to parse AI response. Please try again.');
    }
  }
}