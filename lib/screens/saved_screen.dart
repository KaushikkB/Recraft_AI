import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recraft_provider.dart';
import '../widgets/idea_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Ideas'),
      ),
      body: Consumer<ReCraftProvider>(
        builder: (context, provider, child) {
          final savedItems = provider.savedItems;

          if (savedItems.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savedItems.length,
            itemBuilder: (context, index) {
              final savedItem = savedItems[index];
              return Column(
                children: [
                  // Header with object info
                  Card(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.recycling, color: Colors.green[700], size: 20),
                      ),
                      title: Text(
                        savedItem.objectName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${savedItem.ideas.length} ideas • ${_formatDate(savedItem.savedAt)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteItem(context, savedItem.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Saved ideas
                  ...savedItem.ideas.map((idea) => IdeaCard(
                    idea: idea,
                    onGenerateImage: null, // No generation for saved items
                    isGeneratingImage: false,
                  )).toList(),

                  const Divider(height: 32),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Saved Ideas Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save your favorite upcycling ideas to find them here later',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.home),
              label: const Text('Browse Ideas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _deleteItem(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Saved Item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ReCraftProvider>(context, listen: false).deleteItem(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}