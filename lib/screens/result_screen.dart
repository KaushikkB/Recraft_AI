import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recraft_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/idea_card.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({super.key, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<void> _processingFuture;
  int _generatingImageIndex = -1;

  @override
  void initState() {
    super.initState();
    _processingFuture = _processImage();
  }

  Future<void> _processImage() async {
    try {
      await Provider.of<ReCraftProvider>(context, listen: false)
          .processImage(widget.imagePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    }
  }

  Future<void> _generateImageForIdea(int index) async {
    setState(() {
      _generatingImageIndex = index;
    });

    try {
      final provider = Provider.of<ReCraftProvider>(context, listen: false);
      final idea = provider.currentIdeas[index];
      await provider.generateIdeaImage(idea, index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating image: $e')),
      );
    } finally {
      setState(() {
        _generatingImageIndex = -1;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcycling Ideas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveIdeas,
            tooltip: 'Save Ideas',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _processingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Analyzing your image...');
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          return Consumer<ReCraftProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const LoadingIndicator(message: 'Generating ideas...');
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
              'Processing Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
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
                          'Detected Object:',
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