import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ClarifaiClassifier {
  static const String apiKey = 'b58f56f8e27d4570834034294e7f43c5';
  static const String userId = 'f7012bqm51i3';
  static const String appId = 'recraftai';
  static const String apiUrl = 'https://api.clarifai.com/v2/models/general-image-recognition/versions/aa7f35c01e0642fda5cf400f543e7c40/outputs';

  Future<List<Map<String, dynamic>>> classifyImageWithOptions(File image) async {
    try {
      print('🔄 Sending image to Clarifai for classification...');

      // Validate image file
      if (!await image.exists()) {
        print('❌ Image file does not exist');
        return getFallbackOptions();
      }

      // Read image as base64
      final imageBytes = await image.readAsBytes();

      if (imageBytes.isEmpty) {
        print('❌ Image file is empty');
        return getFallbackOptions();
      }

      final base64Image = base64Encode(imageBytes);
      print('📊 Image encoded, size: ${base64Image.length} bytes');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Key $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_app_id': {
            'user_id': userId,
            'app_id': appId
          },
          'inputs': [
            {
              'data': {
                'image': {
                  'base64': base64Image
                }
              }
            }
          ]
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 Clarifai response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final outputs = data['outputs'] as List;

        if (outputs.isNotEmpty && outputs[0]['data'] != null) {
          final concepts = outputs[0]['data']['concepts'] as List;

          if (concepts != null && concepts.isNotEmpty) {
            // Get top 6 concepts for user selection
            final topConcepts = concepts.take(6).map((concept) {
              final conceptName = concept['name'] as String;
              final confidence = concept['value'] as double;
              return {
                'name': conceptName,
                'confidence': confidence,
                'displayName': _getDisplayName(conceptName)
              };
            }).toList();

            print('🎯 Clarifai found ${topConcepts.length} concepts');

            // Filter out low confidence options
            final filteredConcepts = topConcepts.where((concept) =>
            (concept['confidence'] as double) > 0.5).toList();

            if (filteredConcepts.isNotEmpty) {
              return filteredConcepts;
            }
          }
        }
      } else {
        print('❌ Clarifai API error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Clarifai classification error: $e');
    }

    print('⚠️ Using fallback options');
    return getFallbackOptions();
  }

  List<Map<String, dynamic>> getFallbackOptions() {
    return [
      {'name': 'chair', 'confidence': 0.95, 'displayName': 'Chair'},
      {'name': 'table', 'confidence': 0.90, 'displayName': 'Table'},
      {'name': 'clock', 'confidence': 0.85, 'displayName': 'Clock'},
      {'name': 'lamp', 'confidence': 0.80, 'displayName': 'Lamp'},
      {'name': 'bottle', 'confidence': 0.75, 'displayName': 'Bottle'},
      {'name': 'frame', 'confidence': 0.70, 'displayName': 'Picture Frame'},
    ];
  }

  String _getDisplayName(String concept) {
    final displayMap = {
      'time': 'Clock',
      'clock': 'Clock',
      'analogue': 'Analog Clock',
      'watch': 'Watch',
      'alarm clock': 'Alarm Clock',
      'furniture': 'Furniture',
      'chair': 'Chair',
      'table': 'Table',
      'lamp': 'Lamp',
      'bottle': 'Bottle',
      'vase': 'Vase',
      'frame': 'Picture Frame',
      'box': 'Box',
      'glass': 'Glass Item',
      'wood': 'Wooden Item',
      'metal': 'Metal Item',
      'plastic': 'Plastic Item',
      'electronics': 'Electronic Item',
      'tool': 'Tool',
      'kitchen': 'Kitchen Item',
      'home': 'Home Decor',
      'office': 'Office Item',
    };

    return displayMap[concept] ?? concept;
  }
}