import 'dart:io';
import 'clarifai_classifier.dart';

/// Main classifier service that uses Clarifai API
class ClassifierService {
  final ClarifaiClassifier _clarifaiClassifier = ClarifaiClassifier();
  bool _isInitialized = false;

  /// Initialize the classifier service
  Future<void> initialize() async {
    try {
      _isInitialized = true;
      print('✅ Classifier service initialized with Clarifai API');
    } catch (e) {
      print('❌ Error initializing classifier: $e');
      _isInitialized = false;
    }
  }

  /// Classify an image and return multiple options for user selection
  Future<List<Map<String, dynamic>>> classifyImageWithOptions(File image) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('🔄 Starting image classification with Clarifai...');
      final options = await _clarifaiClassifier.classifyImageWithOptions(image);
      return options;
    } catch (e) {
      print('❌ Classification failed: $e');
      return _clarifaiClassifier.getFallbackOptions(); // Fixed: now public method
    }
  }
  /// Clean up resources
  void dispose() {
    _isInitialized = false;
    print('🔚 Classifier service disposed');
  }
}

