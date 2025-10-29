import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About ReCraft AI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon and Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.recycling,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ReCraft AI',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reinvent. Reuse. Reimagine.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Mission Section
            const Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ReCraft AI empowers creative sustainability by transforming everyday items '
                  'into unique, upcycled treasures. We believe in reducing waste through '
                  'innovation and creativity, making sustainable living accessible and '
                  'enjoyable for everyone.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // How It Works
            const Text(
              'How It Works',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(
              '1. Capture',
              'Take a photo of any item you want to upcycle',
              Icons.photo_camera,
            ),
            _buildStep(
              '2. Analyze',
              'AI identifies your item and understands its potential',
              Icons.auto_awesome,
            ),
            _buildStep(
              '3. Create',
              'Get AI-generated upcycling ideas with materials and steps',
              Icons.lightbulb_outline,
            ),
            _buildStep(
              '4. Visualize',
              'See your transformed item with AI-generated mockups',
              Icons.visibility,
            ),
            const SizedBox(height: 32),

            // Technology
            const Text(
              'Technology',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Powered by:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('• TensorFlow Lite - On-device object recognition'),
                  Text('• Hugging Face - AI-powered idea generation'),
                  Text('• Replicate - Image transformation visualization'),
                  Text('• Flutter - Cross-platform mobile framework'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sustainability Impact
            const Text(
              'Sustainability Impact',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.eco, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Reduces waste by promoting item reuse'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.energy_savings_leaf, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Lowers carbon footprint from manufacturing'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.psychology, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Encourages creative problem-solving'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Join the upcycling revolution. One item at a time.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}