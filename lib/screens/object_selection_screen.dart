import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recraft_provider.dart';
import 'result_screen.dart';

class ObjectSelectionScreen extends StatefulWidget {
  final String imagePath;

  const ObjectSelectionScreen({super.key, required this.imagePath});

  @override
  State<ObjectSelectionScreen> createState() => _ObjectSelectionScreenState();
}

class _ObjectSelectionScreenState extends State<ObjectSelectionScreen> {
  bool _initialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDetection();
  }

  Future<void> _initializeDetection() async {
    try {
      print('🔄 Initializing object detection...');
      final file = File(widget.imagePath);

      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final fileSize = await file.length();
      print('📊 Image file size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // Start classification
      await Provider.of<ReCraftProvider>(context, listen: false)
          .processImageWithOptions(widget.imagePath);

      setState(() {
        _initialized = true;
      });

    } catch (e) {
      print('❌ Error initializing detection: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Object Type'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ReCraftProvider>(
        builder: (context, provider, child) {
          // Show error if initialization failed
          if (_hasError) {
            return _buildErrorState(_errorMessage ?? 'Unknown error occurred', context);
          }

          // Show loading while initializing or processing
          if (!_initialized || provider.isLoading) {
            return _buildLoadingState();
          }

          // Show error if classification failed
          if (provider.classificationError != null) {
            return _buildErrorState(provider.classificationError!, context);
          }

          // Show empty state if no options
          if (provider.detectionOptions.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildOptionsList(provider, context);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Analyzing your image...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Analysis Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error.contains('Image file not found')
                  ? 'The image could not be found. Please try again.'
                  : 'We encountered an error while analyzing your image.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Take New Photo'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _retryDetection,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'No Objects Detected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try with a clearer image or different object',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Take New Photo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList(ReCraftProvider provider, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'What did we find?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI detected these objects in your image. Select the correct one:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Image preview
          _buildImagePreview(),
          const SizedBox(height: 24),

          // Options list
          const Text(
            'Select Object Type:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          ...provider.detectionOptions.map((option) =>
              _buildOptionCard(option, provider, context)),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: FileImage(File(widget.imagePath)),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option, ReCraftProvider provider, BuildContext context) {
    final displayName = option['displayName'] as String;
    final confidence = option['confidence'] as double;
    final confidencePercent = (confidence * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForObject(displayName),
            color: Colors.green[700],
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '$confidencePercent% confidence',
          style: TextStyle(
            color: confidence > 0.7 ? Colors.green : Colors.orange,
          ),
        ),
        trailing: confidence > 0.8
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'High',
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            : null,
        onTap: () => _onOptionSelected(option, provider, context),
      ),
    );
  }

  IconData _getIconForObject(String displayName) {
    final lowerName = displayName.toLowerCase();

    if (lowerName.contains('clock') || lowerName.contains('watch')) {
      return Icons.access_time;
    } else if (lowerName.contains('chair')) {
      return Icons.chair;
    } else if (lowerName.contains('table')) {
      return Icons.table_restaurant;
    } else if (lowerName.contains('lamp')) {
      return Icons.light;
    } else if (lowerName.contains('bottle') || lowerName.contains('vase')) {
      return Icons.local_drink;
    } else if (lowerName.contains('frame')) {
      return Icons.image;
    } else if (lowerName.contains('box')) {
      return Icons.inventory_2;
    } else {
      return Icons.category;
    }
  }

  void _onOptionSelected(Map<String, dynamic> option, ReCraftProvider provider, BuildContext context) {
    final objectName = option['name'] as String;
    final displayName = option['displayName'] as String;

    // Navigate directly to result screen - let it handle the loading
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          imagePath: widget.imagePath,
          objectName: objectName,
          displayName: displayName,
        ),
      ),
    );
  }

  void _retryDetection() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _initialized = false;
    });
    _initializeDetection();
  }
}