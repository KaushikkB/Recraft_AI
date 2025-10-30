import 'dart:io';
import 'package:flutter/material.dart';
import '../models/idea_model.dart';
import '../models/saved_item_model.dart';
import '../services/classifier.dart';
import '../services/idea_generator.dart';
import '../services/image_generator.dart';
import '../services/local_storage.dart';

class ReCraftProvider with ChangeNotifier {
  final ClassifierService _classifier = ClassifierService();
  final IdeaGeneratorService _ideaGenerator = IdeaGeneratorService();
  final ImageGeneratorService _imageGenerator = ImageGeneratorService();
  final LocalStorageService _localStorage = LocalStorageService();

  // State variables
  bool _isLoading = false;
  String _currentObject = '';
  String? _currentImagePath;
  List<Map<String, dynamic>> _detectionOptions = [];
  List<IdeaModel> _currentIdeas = [];
  List<SavedItemModel> _savedItems = [];
  String? _classificationError;

  // Getters
  bool get isLoading => _isLoading;
  String get currentObject => _currentObject;
  String? get currentImagePath => _currentImagePath;
  List<Map<String, dynamic>> get detectionOptions => _detectionOptions;
  List<IdeaModel> get currentIdeas => _currentIdeas;
  List<SavedItemModel> get savedItems => _savedItems;
  String? get classificationError => _classificationError;

  /// Initialize the app services
  Future<void> initializeApp() async {
    try {
      await _classifier.initialize();
      await _ideaGenerator.initialize(); // Fixed: Added await
      await _localStorage.initialize();
      await _loadSavedItems(); // Fixed: Added await
      print('✅ App initialized successfully');
    } catch (e) {
      print('❌ Error initializing app: $e');
    }
  }

  /// Process an image and get detection options for user selection
  Future<void> processImageWithOptions(String imagePath) async {
    try {
      _setLoading(true);
      _classificationError = null;
      _currentImagePath = imagePath;
      _detectionOptions.clear();
      notifyListeners();

      print('🔄 Starting image processing with options...');

      // Get multiple detection options
      final file = File(imagePath);
      _detectionOptions = await _classifier.classifyImageWithOptions(file);
      print('✅ Got ${_detectionOptions.length} detection options');
      notifyListeners();

    } catch (e) {
      print('❌ Error processing image: $e');
      _classificationError = 'Failed to process image: $e';
      notifyListeners();
      throw Exception('Failed to process image: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// User selects an object from the options
  Future<void> selectObject(String objectName, String displayName) async {
    try {
      _setLoading(true);
      _currentObject = displayName;
      notifyListeners();

      print('🔄 Generating upcycling ideas for: $objectName ($displayName)');
      _currentIdeas = await _ideaGenerator.generateIdeas(objectName);
      print('✅ Generated ${_currentIdeas.length} ideas');
      notifyListeners();

    } catch (e) {
      print('❌ Error generating ideas: $e');
      throw Exception('Failed to generate ideas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate image for a specific idea
  Future<String?> generateIdeaImage(IdeaModel idea, int ideaIndex) async {
    try {
      _setLoading(true);

      final imageUrl = await _imageGenerator.generateImage(
          _currentObject,
          '${idea.title}: ${idea.description}'
      );

      if (imageUrl != null) {
        // Update the idea with generated image URL
        _currentIdeas[ideaIndex] = IdeaModel(
          title: idea.title,
          description: idea.description,
          materials: idea.materials,
          steps: idea.steps,
          generatedImageUrl: imageUrl,
          timestamp: idea.timestamp,
        );
        notifyListeners();
      }

      return imageUrl;
    } catch (e) {
      print('❌ Error generating idea image: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Save current ideas to local storage
  Future<void> saveCurrentIdeas() async {
    try {
      if (_currentIdeas.isEmpty || _currentImagePath == null) return;

      final savedItem = SavedItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        objectName: _currentObject,
        originalImagePath: _currentImagePath!,
        ideas: List.from(_currentIdeas),
        savedAt: DateTime.now(),
      );

      await _localStorage.saveItem(savedItem);
      await _loadSavedItems();

      print('✅ Ideas saved successfully');

    } catch (e) {
      print('❌ Error saving ideas: $e');
      throw Exception('Failed to save ideas');
    }
  }

  /// Delete a saved item
  Future<void> deleteItem(String id) async {
    try {
      await _localStorage.deleteItem(id);
      await _loadSavedItems();
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting item: $e');
      throw Exception('Failed to delete item');
    }
  }

  /// Load saved items from local storage
  Future<void> _loadSavedItems() async {
    try {
      _savedItems = await _localStorage.getSavedItems();
      notifyListeners();
    } catch (e) {
      print('❌ Error loading saved items: $e');
    }
  }

  /// Clear current session
  void clearCurrentSession() {
    _currentObject = '';
    _currentImagePath = null;
    _currentIdeas.clear();
    _detectionOptions.clear();
    _classificationError = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }
}