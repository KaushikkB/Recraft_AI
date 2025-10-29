import 'package:flutter/material.dart';
import '../models/idea_model.dart';

/// Custom card widget for displaying upcycling ideas
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
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.error_outline, color: Colors.grey),
              );
            },
          ),
        ),
      ],
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