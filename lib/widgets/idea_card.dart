import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/idea_model.dart';

class IdeaCard extends StatelessWidget {
  final IdeaModel idea;
  final VoidCallback? onGenerateImage;
  final bool isGeneratingImage;

  const IdeaCard({
    super.key,
    required this.idea,
    this.onGenerateImage,
    this.isGeneratingImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              idea.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              idea.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Materials
            _buildSection(
              context,
              'Materials Needed:',
              idea.materials,
              Icons.build_circle_outlined,
            ),
            const SizedBox(height: 8),

            // Steps
            _buildSection(
              context,
              'Steps:',
              idea.steps,
              Icons.list_alt_outlined,
            ),
            const SizedBox(height: 12),

            // Generated Image or Generate Button
            if (idea.generatedImageUrl != null)
              _buildGeneratedImage(context, idea.generatedImageUrl!)
            else if (onGenerateImage != null)
              _buildGenerateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '• $item',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )),
      ],
    );
  }

  Widget _buildGeneratedImage(BuildContext context, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visual Preview:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImageWidget(imageUrl),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    print('🖼️ Building image widget for URL: ${imageUrl.substring(0, 50)}...');

    // Check if it's a base64 image
    if (imageUrl.startsWith('data:image')) {
      try {
        // Extract base64 data (remove "data:image/jpeg;base64," part)
        final parts = imageUrl.split(',');
        if (parts.length != 2) {
          throw Exception('Invalid base64 format');
        }

        final base64Data = parts[1];
        final imageBytes = base64.decode(base64Data);

        print('✅ Successfully decoded base64 image, bytes: ${imageBytes.length}');

        return Image.memory(
          imageBytes,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error displaying base64 image: $error');
            return _buildImageError('Failed to display image');
          },
        );
      } catch (e) {
        print('❌ Base64 decoding error: $e');
        return _buildImageError('Image decoding failed');
      }
    }
    // Check if it's a network URL
    else if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Network image error: $error');
          return _buildImageError('Failed to load image');
        },
      );
    }
    // Invalid URL
    else {
      return _buildImageError('Invalid image URL');
    }
  }

  Widget _buildImageError(String message) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.grey, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isGeneratingImage ? null : onGenerateImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: isGeneratingImage
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.visibility, size: 18),
        label: Text(isGeneratingImage ? 'Generating...' : 'Visualize This Idea'),
      ),
    );
  }
}