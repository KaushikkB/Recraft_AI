import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recraft_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/idea_card.dart';
import 'object_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final String objectName;
  final String displayName;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.objectName,
    required this.displayName,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<void> _processingFuture;
  int _generatingImageIndex = -1;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processingFuture = _generateIdeas();
  }

  Future<void> _generateIdeas() async {
    try {
      print('🔄 Generating ideas for: ${widget.objectName} (${widget.displayName})');
      await Provider.of<ReCraftProvider>(context, listen: false)
          .selectObject(widget.objectName, widget.displayName);
      print('✅ Ideas generated successfully');
    } catch (e) {
      print('❌ Error generating ideas in ResultScreen: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _generateImageForIdea(int index) async {
    setState(() {
      _generatingImageIndex = index;
    });

    try {
      final provider = Provider.of<ReCraftProvider>(context, listen: false);
      final idea = provider.currentIdeas[index];

      print('🔄 Starting image generation for idea $index: ${idea.title}');

      await provider.generateIdeaImage(idea, index);

      // Force a refresh of the UI
      if (mounted) {
        setState(() {});
      }

      print('✅ Image generation completed for idea $index');

    } catch (e) {
      print('❌ Error generating image for idea $index: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _generatingImageIndex = -1;
        });
      }
    }
  }

  Future<void> _saveIdeas() async {
    try {
      await Provider.of<ReCraftProvider>(context, listen: false).saveCurrentIdeas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ideas saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving ideas: $e')),
      );
    }
  }

  void _retryClassification() {
    // Navigate back to object selection
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ObjectSelectionScreen(imagePath: widget.imagePath),
      ),
    );
  }

  void _retryIdeas() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _processingFuture = _generateIdeas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcycling Ideas'),
        actions: [
          Consumer<ReCraftProvider>(
            builder: (context, provider, child) {
              if (provider.currentIdeas.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveIdeas,
                  tooltip: 'Save Ideas',
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _processingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Generating creative ideas...');
          }

          if (_hasError) {
            return _buildErrorState(_errorMessage ?? 'Unknown error occurred');
          }

          return Consumer<ReCraftProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const LoadingIndicator(message: 'Processing...');
              }

              if (provider.currentIdeas.isEmpty) {
                return _buildNoIdeasState(provider);
              }

              return _buildResults(provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to Generate Ideas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error.contains('NotInitializedError')
                  ? 'Service not ready. Please try again.'
                  : 'We encountered an error while generating ideas.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _retryIdeas,
                  child: const Text('Try Again'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _retryClassification,
                  child: const Text('Choose Different Object'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoIdeasState(ReCraftProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Ideas Generated',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'We couldn\'t generate ideas for this item.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retryClassification,
              child: const Text('Try Different Object'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ReCraftProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original Image and Object Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Image thumbnail
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(widget.imagePath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Object info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Object:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.currentObject,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.currentIdeas.length} creative ideas generated',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Ideas List
          const Text(
            'Upcycling Ideas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          ...provider.currentIdeas.asMap().entries.map((entry) {
            final index = entry.key;
            final idea = entry.value;

            return IdeaCard(
              idea: idea,
              onGenerateImage: () => _generateImageForIdea(index),
              isGeneratingImage: _generatingImageIndex == index,
            );
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}