import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageGeneratorService {
  // Runware API Configuration
  static const String _runwareUrl = 'https://api.runware.io/v1/inference/image-to-image';
  static const String _apiKey = 'your_runware_api_key_here'; // Replace with your actual Runware key

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      if (_apiKey.isEmpty || _apiKey.contains('your_runware_api_key')) {
        throw Exception('Please set your Runware API key');
      }
      _isInitialized = true;
      print('✅ Runware Image Generator initialized');
    } catch (e) {
      print('❌ Runware service initialization failed: $e');
      rethrow;
    }
  }

  Future<String?> generateImage(String objectName, String ideaDescription) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final prompt = _buildImagePrompt(objectName, ideaDescription);
      print('🎨 Generating AI image with Runware...');
      print('📝 Prompt: $prompt');

      // For Runware, we need to use their specific API format
      // Since we don't have source images, we'll use text-to-image
      final response = await http.post(
        Uri.parse('https://api.runware.io/v1/inference/text-to-image'), // Using text-to-image endpoint
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'prompt': prompt,
          'negative_prompt': 'blurry, low quality, distorted, ugly, bad anatomy',
          'width': 512,
          'height': 512,
          'samples': 1,
          'num_inference_steps': 20,
          'guidance_scale': 7.5,
          'seed': null,
        }),
      ).timeout(const Duration(seconds: 120));

      print('📡 Runware response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Runware returns image in their specific format
        if (data['data'] != null && data['data'].isNotEmpty) {
          final imageUrl = data['data'][0]['url'] as String?;

          if (imageUrl != null) {
            print('✅ Runware image generated successfully: $imageUrl');
            return imageUrl;
          }
        }

        throw Exception('Runware did not return image URL');
      } else {
        throw Exception('Runware API error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Runware image generation failed: $e');
      // Return a placeholder instead of throwing error
      return _getPlaceholderImageUrl(objectName, ideaDescription);
    }
  }

  String _buildImagePrompt(String objectName, String ideaDescription) {
    return '''
Professional product photography of a creatively upcycled $objectName: $ideaDescription
Studio lighting, clean white background, high detail, photorealistic, 
sustainable design, beautiful composition, 8k resolution, masterpiece
''';
  }

  String _getPlaceholderImageUrl(String objectName, String ideaDescription) {
    // Fallback placeholder
    return 'https://via.placeholder.com/512/2E7D32/FFFFFF?text=Upcycled+${Uri.encodeComponent(objectName)}';
  }
}