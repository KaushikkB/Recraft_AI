import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ClarifaiClassifier {
  // Updated Clarifai API - you need both User ID and App ID
  static const String apiKey = 'b58f56f8e27d4570834034294e7f43c5'; // Replace with your actual key
  static const String userId = 'f7012bqm51i3'; // Replace with your user ID
  static const String appId = 'recraftai';   // Replace with your app ID
  static const String apiUrl = 'https://api.clarifai.com/v2/models/general-image-recognition/versions/aa7f35c01e0642fda5cf400f543e7c40/outputs';

  Future<List<Map<String, dynamic>>> classifyImageWithOptions(File image) async {
  try {
  print('🔄 Sending image to Clarifai for classification...');

  // Read image as base64
  final imageBytes = await image.readAsBytes();
  final base64Image = base64Encode(imageBytes);

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
  // Get top 8 concepts for user selection
  final topConcepts = concepts.take(8).map((concept) {
  final conceptName = concept['name'] as String;
  final confidence = concept['value'] as double;
  return {
  'name': conceptName,
  'confidence': confidence,
  'displayName': _getDisplayName(conceptName)
  };
  }).toList();

  print('🎯 Clarifai Top Concepts:');
  for (final concept in topConcepts) {
  final confidencePercent = ((concept['confidence']! as num )* 100).toStringAsFixed(1);
  print('   - ${concept['name']} ($confidencePercent%) -> ${concept['displayName']}');
  }

  return topConcepts;
  } else {
  print('❌ No concepts returned from Clarifai');
  }
  } else {
  print('❌ No outputs from Clarifai');
  }
  } else {
  print('❌ Clarifai API error: ${response.statusCode}');
  print('Response: ${response.body}');
  }
  } catch (e) {
  print('❌ Clarifai classification error: $e');
  }

  // Fallback to default options
  return getFallbackOptions();
  }

  // ADD THIS METHOD HERE - it belongs to ClarifaiClassifier
  List<Map<String, dynamic>> getFallbackOptions() {
  return [
  {'name': 'clock', 'confidence': 0.95, 'displayName': 'Clock'},
  {'name': 'alarm clock', 'confidence': 0.90, 'displayName': 'Alarm Clock'},
  {'name': 'watch', 'confidence': 0.85, 'displayName': 'Watch'},
  {'name': 'furniture', 'confidence': 0.80, 'displayName': 'Furniture'},
  {'name': 'electronics', 'confidence': 0.75, 'displayName': 'Electronic Item'},
  {'name': 'home', 'confidence': 0.70, 'displayName': 'Home Decor'},
  ];
  }

  String _getDisplayName(String concept) {
  // Map technical concepts to user-friendly names
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