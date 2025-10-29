import 'dart:io';
import 'package:flutter/material.dart';
import '../models/idea_model.dart';
import '../models/saved_item_model.dart';
import '../services/classifier.dart';
import '../services/idea_generator.dart';
import '../services/image_generator.dart';
import '../services/local_storage.dart';

/// Main provider for managing app state and business logic
class ReCraftProvider with ChangeNotifier {
  final ClassifierService _classifier = ClassifierService();
  final IdeaGeneratorService _ideaGenerator = IdeaGeneratorService();
  final ImageGeneratorService _imageGenerator = ImageGeneratorService();
  final LocalStorageService _localStorage = LocalStorageService();

  // State variables
  bool _isLoading = false;
  String _currentObject = '';
  String? _currentImagePath;
  List<IdeaModel> _currentIdeas = [];
  List<SavedItemModel> _savedItems = [];

  // Getters
  bool get isLoading => _isLoading;
  String get currentObject => _currentObject;
  String? get currentImagePath => _currentImagePath;
  List<IdeaModel> get currentIdeas => _currentIdeas;
  List<SavedItemModel> get savedItems => _savedItems;

  /// Initialize the app services
  Future<void> initializeApp() async {
    try {
      await _classifier.initialize();
      await _localStorage.initialize();
      await _loadSavedItems();
    } catch (e) {
      print('❌ Error initializing app: $e');
    }
  }

  /// Process an image: classify → generate ideas
  Future<void> processImage(String imagePath) async {
    try {
      _setLoading(true);
      _currentImagePath = imagePath;

      // Step 1: Classify image
      final file = File(imagePath);
      _currentObject = await _classifier.classifyImage(file);
      notifyListeners();

      // Step 2: Generate ideas
      _currentIdeas = await _ideaGenerator.generateIdeas(_currentObject);
      notifyListeners();

    } catch (e) {
      print('❌ Error processing image: $e');
      throw Exception('Failed to process image: $e');
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