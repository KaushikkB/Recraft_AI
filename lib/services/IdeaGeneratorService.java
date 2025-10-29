import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/idea_model.dart';

/// Service for generating upcycling ideas using Hugging Face API
class IdeaGeneratorService {
  static const String baseUrl = 'https://api-inference.huggingface.co/models';
  static const String model = 'microsoft/DialoGPT-medium'; // Alternative free model
  
  /// Generate upcycling ideas for a detected object
  Future<List<IdeaModel>> generateIdeas(String objectName) async {
    try {
      final token = dotenv.env['HUGGING_FACE_TOKEN'];
      if (token == null) {
        throw Exception('Hugging Face token not configured');
      }
      
      final prompt = '''
Generate 3 creative, sustainable DIY upcycling ideas for an old $objectName.
For each idea, provide:
1. A creative title
2. A brief description (1-2 sentences)
3. List of required materials
4. Step-by-step instructions (3-4 steps each)

Format the response as a JSON array where each idea has:
- "title"
- "description" 
- "materials" (array)
- "steps" (array)
''';

      final response = await http.post(
        Uri.parse('$baseUrl/$model'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': prompt,
          'parameters': {
            'max_length': 500,
            'temperature': 0.9,
            'do_sample': true,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return _parseResponse(response.body, objectName);
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error generating ideas: $e');
      // Return fallback ideas if API fails
      return _getFallbackIdeas(objectName);
    }
  }

  /// Parse API response into IdeaModel objects
  List<IdeaModel> _parseResponse(String responseBody, String objectName) {
    try {
      final data = json.decode(responseBody);
      final generatedText = data[0]['generated_text'] as String?;
      
      if (generatedText != null) {
        // Try to extract JSON from the response
        final jsonMatch = RegExp(r'\[.*\]').firstMatch(generatedText);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0);
          final ideasJson = json.decode(jsonStr!) as List;
          return ideasJson.map((ideaJson) {
            return IdeaModel(
              title: ideaJson['title'] ?? 'Creative Upcycling Idea',
              description: ideaJson['description'] ?? 'Transform your $objectName into something new and useful.',
              materials: List<String>.from(ideaJson['materials'] ?? ['Basic crafting supplies']),
              steps: List<String>.from(ideaJson['steps'] ?? ['Clean the item', 'Apply your design', 'Let it dry']),
              timestamp: DateTime.now(),
            );
          }).toList();
        }
      }
      
      // If JSON parsing fails, return fallback
      return _getFallbackIdeas(objectName);
    } catch (e) {
      print('❌ Error parsing API response: $e');
      return _getFallbackIdeas(objectName);
    }
  }

  /// Provide fallback ideas when API is unavailable
  List<IdeaModel> _getFallbackIdeas(String objectName) {
    return [
      IdeaModel(
        title: 'Eco-Friendly Planter',
        description: 'Transform your $objectName into a beautiful planter for herbs or small plants.',
        materials: ['$objectName', 'Potting soil', 'Small plants', 'Drill (if needed for drainage)'],
        steps: [
          'Clean and prepare the $objectName',
          'Add drainage holes if necessary',
          'Fill with potting soil and plants',
          'Water and display in your space'
        ],
        timestamp: DateTime.now(),
      ),
      IdeaModel(
        title: 'Creative Storage Solution',
        description: 'Repurpose the $objectName into unique storage for your home.',
        materials: ['$objectName', 'Paint or stain', 'Brushes', 'Decorative elements'],
        steps: [
          'Clean and sand the $objectName',
          'Apply your chosen finish',
          'Add any decorative elements',
          'Use for storing items creatively'
        ],
        timestamp: DateTime.now(),
      ),
      IdeaModel(
        title: 'Artistic Display Piece',
        description: 'Turn the $objectName into a conversation-starting art piece.',
        materials: ['$objectName', 'Acrylic paints', 'Brushes', 'Clear sealant'],
        steps: [
          'Clean and prime the surface',
          'Paint your design or pattern',
          'Allow to dry completely',
          'Apply protective sealant'
        ],
        timestamp: DateTime.now(),
      ),
    ];
  }
}