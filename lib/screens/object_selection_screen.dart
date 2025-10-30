import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recraft_provider.dart';
import 'result_screen.dart'; // Add this import

class ObjectSelectionScreen extends StatelessWidget {
  final String imagePath;

  const ObjectSelectionScreen({super.key, required this.imagePath});

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
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.detectionOptions.isEmpty) {
            return _buildEmptyState(provider, context);
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

  Widget _buildEmptyState(ReCraftProvider provider, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No objects detected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please try with a different image',
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

          ...provider.detectionOptions.map((option) => _buildOptionCard(option, provider, context)),
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
            image: FileImage(File(imagePath)), // Fixed: Added File()
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
    if (displayName.toLowerCase().contains('clock') || displayName.toLowerCase().contains('watch')) {
      return Icons.access_time;
    } else if (displayName.toLowerCase().contains('chair')) {
      return Icons.chair;
    } else if (displayName.toLowerCase().contains('table')) {
      return Icons.table_restaurant;
    } else if (displayName.toLowerCase().contains('lamp')) {
      return Icons.light;
    } else if (displayName.toLowerCase().contains('bottle') || displayName.toLowerCase().contains('vase')) {
      return Icons.local_drink;
    } else if (displayName.toLowerCase().contains('frame')) {
      return Icons.image;
    } else if (displayName.toLowerCase().contains('box')) {
      return Icons.inventory_2;
    } else {
      return Icons.category;
    }
  }

  void _onOptionSelected(Map<String, dynamic> option, ReCraftProvider provider, BuildContext context) {
    final objectName = option['name'] as String;
    final displayName = option['displayName'] as String;

    // Navigate to result screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FutureBuilder(
          future: provider.selectObject(objectName, displayName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: const Text('Generating Ideas')),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Creating upcycling ideas...'),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return ResultScreen(imagePath: imagePath);
            }
          },
        ),
      ),
    );
  }
}