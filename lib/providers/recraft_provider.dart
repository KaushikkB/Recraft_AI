import 'dart:io';
import 'package:flutter/material.dart';
import '../models/idea_model.dart';
import '../models/saved_item_model.dart';
import '../services/classifier.dart';
import '../services/idea_generator.dart';
import '../services/image_generator.dart';
import '../services/local_storage.dart';
import 'dart:math';

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
  bool _appInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  String get currentObject => _currentObject;
  String? get currentImagePath => _currentImagePath;
  List<Map<String, dynamic>> get detectionOptions => _detectionOptions;
  List<IdeaModel> get currentIdeas => _currentIdeas;
  List<SavedItemModel> get savedItems => _savedItems;
  String? get classificationError => _classificationError;
  bool get appInitialized => _appInitialized;

  /// Initialize the app services
  Future<void> initializeApp() async {
    try {
      print('🚀 Initializing ReCraft AI services...');
      print('📝 Using Mistral 7B for ideas & Stable Diffusion 3.5 Flash for images');

      // Initialize all services in parallel
      await Future.wait([
        _classifier.initialize(),
        _ideaGenerator.initialize(),
        _imageGenerator.initialize(),
        _localStorage.initialize(),
      ], eagerError: true);

      await _loadSavedItems();
      _appInitialized = true;

      print('✅ ReCraft AI initialized successfully');

    } catch (e) {
      print('❌ App initialization error: $e');
      _appInitialized = true; // Allow app to function
    }
  }

  /// Process an image and get detection options
  Future<void> processImageWithOptions(String imagePath) async {
    try {
      _setLoading(true);
      _classificationError = null;
      _currentImagePath = imagePath;
      _detectionOptions.clear();

      print('📸 Processing image: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      _detectionOptions = await _classifier.classifyImageWithOptions(file);
      print('🎯 Found ${_detectionOptions.length} objects');

      if (_detectionOptions.isEmpty) {
        throw Exception('No objects detected in the image. Please try with a different image.');
      }

    } catch (e) {
      print('❌ Image processing error: $e');
      _classificationError = 'Image analysis failed: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// User selects an object - generates ideas with Mistral 7B
  Future<void> selectObject(String objectName, String displayName) async {
    try {
      _setLoading(true);
      _currentObject = displayName;
      _currentIdeas.clear();

      print('💡 Generating ideas with Mistral 7B for: $objectName');

      // Generate upcycling ideas with Mistral 7B
      _currentIdeas = await _ideaGenerator.generateIdeas(objectName);
      print('✅ Generated ${_currentIdeas.length} Mistral-powered ideas');

    } catch (e) {
      print('❌ Mistral idea generation failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Generate image with Stable Diffusion 3.5 Flash
  Future<String?> generateIdeaImage(IdeaModel idea, int ideaIndex) async {
    try {
      _setLoading(true);

      print('🎨 Generating image with SD 3.5 Flash for: ${idea.title}');
      print('📝 Idea index: $ideaIndex');

      final imageUrl = await _imageGenerator.generateImage(
          _currentObject,
          '${idea.title}: ${idea.description}'
      );

      // Debug the returned image URL
      if (imageUrl != null) {
        print('🖼️ Image URL received for idea $ideaIndex');
        print('🖼️ URL type: ${imageUrl.startsWith('data:image') ? 'Base64' : 'Network'}');
        print('🖼️ URL length: ${imageUrl.length}');
      } else {
        print('❌ Image URL is null for idea $ideaIndex');
        return null;
      }

      // Create updated idea with the image URL
      final updatedIdea = IdeaModel(
        title: idea.title,
        description: idea.description,
        materials: idea.materials,
        steps: idea.steps,
        generatedImageUrl: imageUrl,
        timestamp: idea.timestamp,
      );

      // Update the ideas list
      _currentIdeas[ideaIndex] = updatedIdea;

      print('✅ Updated idea $ideaIndex with image URL');
      print('🔄 Notifying listeners...');

      // Force UI update
      notifyListeners();

      // Wait a bit for UI to update
      await Future.delayed(const Duration(milliseconds: 100));

      print('✅ SD 3.5 Flash image stored successfully in idea $ideaIndex');

      return imageUrl;
    } catch (e) {
      print('❌ SD 3.5 Flash image generation failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Save ideas to local storage
  Future<void> saveCurrentIdeas() async {
    try {
      if (_currentIdeas.isEmpty || _currentImagePath == null) {
        throw Exception('No ideas to save');
      }

      final savedItem = SavedItemModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_${_currentObject}',
        objectName: _currentObject,
        originalImagePath: _currentImagePath!,
        ideas: List.from(_currentIdeas),
        savedAt: DateTime.now(),
      );

      await _localStorage.saveItem(savedItem);
      await _loadSavedItems();

      print('💾 Ideas saved successfully');

    } catch (e) {
      print('❌ Save error: $e');
      throw Exception('Failed to save ideas: ${e.toString()}');
    }
  }

  /// Delete saved item
  Future<void> deleteItem(String id) async {
    try {
      await _localStorage.deleteItem(id);
      await _loadSavedItems();
      notifyListeners();
      print('🗑️ Item deleted successfully');
    } catch (e) {
      print('❌ Delete error: $e');
      throw Exception('Failed to delete item: ${e.toString()}');
    }
  }

  /// Load saved items
  Future<void> _loadSavedItems() async {
    try {
      _savedItems = await _localStorage.getSavedItems();
      notifyListeners();
      print('📂 Loaded ${_savedItems.length} saved items');
    } catch (e) {
      print('❌ Load saved items error: $e');
      rethrow;
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
    print('🧹 Session cleared');
  }

  /// Get app status for debugging
  Map<String, dynamic> get debugInfo {
    return {
      'appInitialized': _appInitialized,
      'servicesInitialized': {
        'classifier': true,
        'ideaGenerator': _ideaGenerator.isInitialized,
        'imageGenerator': _imageGenerator.isInitialized,
        'localStorage': true,
      },
      'aiProviders': {
        'ideas': 'Mistral 7B (OpenRouter)',
        'images': 'Stable Diffusion 3.5 Flash (Stability AI)',
      },
      'currentState': {
        'object': _currentObject,
        'ideasCount': _currentIdeas.length,
        'savedItemsCount': _savedItems.length,
        'isLoading': _isLoading,
      }
    };
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    print('🔚 ReCraftProvider disposed');
    super.dispose();
  }
}