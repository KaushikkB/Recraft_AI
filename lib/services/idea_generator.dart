import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/idea_model.dart';

/// Service for generating upcycling ideas
class IdeaGeneratorService {
  bool _isInitialized = false;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100)); // Simulate initialization
      _isInitialized = true;
      print('✅ Idea Generator service initialized');
    } catch (e) {
      print('❌ Error initializing idea generator: $e');
      _isInitialized = false;
    }
  }

  /// Generate upcycling ideas for a detected object
  Future<List<IdeaModel>> generateIdeas(String objectName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // For now, use mock data since API setup might be complex
      // In production, you would implement the actual API call here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      return _getMockIdeas(objectName);

    } catch (e) {
      print('❌ Error generating ideas: $e');
      return _getMockIdeas(objectName);
    }
  }

  /// Provide mock ideas for testing
  List<IdeaModel> _getMockIdeas(String objectName) {
    // Different ideas based on object type
    if (objectName.contains('chair')) {
      return [
        IdeaModel(
          title: 'Bohemian Hanging Planter Chair',
          description: 'Transform an old chair into a stunning vertical garden display piece.',
          materials: ['Old chair', 'Hanging planters', 'Strong rope or chain', 'Potting soil', 'Trailing plants'],
          steps: [
            'Remove the seat from the chair frame',
            'Attach hanging planters to the seat area',
            'Suspend the chair from a sturdy ceiling hook',
            'Fill planters with soil and trailing plants like ivy or pothos'
          ],
          timestamp: DateTime.now(),
        ),
        IdeaModel(
          title: 'Vintage Bookshelf Side Table',
          description: 'Convert a chair into a unique side table with built-in book storage.',
          materials: ['Chair', 'Wooden plank', 'Sandpaper', 'Wood glue', 'Paint or stain'],
          steps: [
            'Remove the backrest from the chair',
            'Cut a wooden plank to fit the seat area',
            'Sand and finish the wood to your preference',
            'Attach the plank securely to create a table surface'
          ],
          timestamp: DateTime.now(),
        ),
      ];
    } else if (objectName.contains('clock') || objectName.contains('alarm')) {
      return [
        IdeaModel(
          title: 'Steampunk Wall Art Clock',
          description: 'Transform an old alarm clock into unique steampunk-inspired wall art.',
          materials: ['Alarm clock', 'Copper pipes', 'Gears and cogs', 'Wooden board', 'Hot glue'],
          steps: [
            'Carefully disassemble the clock mechanism',
            'Arrange gears and pipes on the wooden board',
            'Secure all elements with strong adhesive',
            'Reattach clock hands for functional art piece'
          ],
          timestamp: DateTime.now(),
        ),
        IdeaModel(
          title: 'Vintage Desk Organizer',
          description: 'Repurpose clock parts into an elegant desk organizer.',
          materials: ['Clock parts', 'Small wooden box', 'Spray paint', 'Clear sealant'],
          steps: [
            'Clean and prepare all clock components',
            'Paint the wooden box in your preferred color',
            'Arrange clock parts as decorative elements',
            'Seal everything with protective coating'
          ],
          timestamp: DateTime.now(),
        ),
      ];
    } else if (objectName.contains('bottle')) {
      return [
        IdeaModel(
          title: 'Elegant Bottle Lamp',
          description: 'Create a beautiful lighting fixture from glass bottles.',
          materials: ['Glass bottle', 'Lamp kit', 'Drill with glass bit', 'Lampshade', 'Decorative sand or stones'],
          steps: [
            'Carefully drill a hole in the bottom of the bottle',
            'Thread lamp wiring through the bottle',
            'Assemble lamp components according to kit instructions',
            'Add decorative elements and attach lampshade'
          ],
          timestamp: DateTime.now(),
        ),
        IdeaModel(
          title: 'Herb Garden in a Bottle',
          description: 'Make a self-contained terrarium for growing herbs indoors.',
          materials: ['Clear bottle', 'Potting soil', 'Small herbs', 'Activated charcoal', 'Decorative stones'],
          steps: [
            'Clean and dry the bottle thoroughly',
            'Layer stones, charcoal, and soil in the bottle',
            'Carefully plant small herb seedlings',
            'Water lightly and place in indirect sunlight'
          ],
          timestamp: DateTime.now(),
        ),
      ];
    } else {
      // Generic ideas for any object
      return [
        IdeaModel(
          title: 'Creative Wall Art',
          description: 'Turn your $objectName into unique wall decor that tells a story.',
          materials: ['$objectName', 'Acrylic paints', 'Brushes', 'Clear sealant', 'Picture hanging hardware'],
          steps: [
            'Clean and prepare the surface',
            'Sketch your design with pencil',
            'Paint with vibrant colors and patterns',
            'Seal and add hanging hardware'
          ],
          timestamp: DateTime.now(),
        ),
        IdeaModel(
          title: 'Functional Storage Solution',
          description: 'Repurpose your $objectName into practical home organization.',
          materials: ['$objectName', 'Storage baskets', 'Paint or finish', 'Mounting hardware'],
          steps: [
            'Reinforce the structure if needed',
            'Add compartments or dividers',
            'Apply your chosen finish',
            'Install in your desired location'
          ],
          timestamp: DateTime.now(),
        ),
        IdeaModel(
          title: 'Garden Feature',
          description: 'Give your $objectName new life as an outdoor garden element.',
          materials: ['$objectName', 'Outdoor sealant', 'Plants or flowers', 'Potting soil'],
          steps: [
            'Weatherproof with outdoor sealant',
            'Add drainage if needed',
            'Incorporate plants creatively',
            'Place in your garden space'
          ],
          timestamp: DateTime.now(),
        ),
      ];
    }
  }
}