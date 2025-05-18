import 'package:flutter/material.dart';

class MicroJournal extends StatelessWidget {
  final void Function(String note) onSave;
  const MicroJournal({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kendime Not', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLength: 280,
              decoration: const InputDecoration(
                hintText: 'Bugün kendine kısa bir not bırak... (280 karakter)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onSave(controller.text);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
