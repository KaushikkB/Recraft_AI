import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageGeneratorService {
  // Stability AI Configuration
  static const String _stabilityApiUrl = 'https://api.stability.ai/v2beta/stable-image/generate/sd3';
  static const String _apiKey = 'sk-KjMgLVvQ18Bed9MBgerx6wTRaoujRLh2IychSsJIFcvS2UnR'; // Replace with your actual Stability AI key

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
  try {
  if (_apiKey.isEmpty || _apiKey.contains('your-stability-ai-api-key')) {
  throw Exception('Please set your Stability AI API key');
  }
  _isInitialized = true;
  print('✅ Stability AI SD 3.5 Flash Image Generator initialized');
  } catch (e) {
  print('❌ Stability AI service initialization failed: $e');
  rethrow;
  }
  }

  Future<String?> generateImage(String objectName, String ideaDescription) async {
  if (!_isInitialized) {
  await initialize();
  }

  try {
  final prompt = _buildImagePrompt(objectName, ideaDescription);
  print('🎨 Generating AI image with Stable Diffusion 3.5 Flash...');
  print('📝 Prompt: $prompt');

  // Create multipart request
  var request = http.MultipartRequest('POST', Uri.parse(_stabilityApiUrl));

  // Add headers
  request.headers['Authorization'] = 'Bearer $_apiKey';
  request.headers['Accept'] = 'image/*';

  // Add fields
  request.fields['prompt'] = prompt;
  request.fields['model'] = 'sd3.5-flash';
  request.fields['output_format'] = 'jpeg';

  // Add empty file as required
  request.files.add(await http.MultipartFile.fromString('none', ''));

  // Send request
  final streamedResponse = await request.send().timeout(const Duration(seconds: 120));
  final response = await http.Response.fromStream(streamedResponse);

  print('📡 Stability AI response status: ${response.statusCode}');

  if (response.statusCode == 200) {
  // Get image bytes directly
  final imageBytes = response.bodyBytes;

  if (imageBytes.isEmpty) {
  throw Exception('Received empty image from Stability AI');
  }

  // Convert to base64 for storage
  final base64Image = base64Encode(imageBytes);
  final imageUrl = 'data:image/jpeg;base64,$base64Image';

  print('✅ SD 3.5 Flash image generated successfully');
  print('📊 Image size: ${imageBytes.length} bytes, Base64 length: ${base64Image.length}');

  return imageUrl;
  } else {
  final errorBody = response.body;
  print('❌ Stability AI error response: $errorBody');
  throw Exception('Stability AI API error ${response.statusCode}');
  }
  } catch (e) {
  print('❌ SD 3.5 Flash image generation failed: $e');
  return _getPlaceholderImageUrl(objectName, ideaDescription);
  }
  }

  String _buildImagePrompt(String objectName, String ideaDescription) {
  return '''
Professional product photography of a creatively upcycled $objectName: $ideaDescription
Studio lighting, clean white background, high detail, photorealistic, 
sustainable design, beautiful composition, masterpiece,
eco-friendly, DIY project, well-crafted, professional finish
''';
  }

  String _getPlaceholderImageUrl(String objectName, String ideaDescription) {
  // Simple placeholder without base64
  return 'https://via.placeholder.com/512/2E7D32/FFFFFF?text=Upcycled+${Uri.encodeComponent(objectName)}';
  }
  }