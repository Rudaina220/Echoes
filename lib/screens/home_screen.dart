import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../db/db_provider.dart';
import '../features/export/pdf_exporter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Echoes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export memories as PDF',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final memories = await ref.read(databaseProvider).allMemories();
                if (memories.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('No memories to export.')),
                  );
                  return;
                }
                await PdfExporter().export(memories);
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
          ),
          IconButton(
            onPressed: () => context.push('/map'),
            icon: const Icon(Icons.map),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Echoes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text('Capture memories with text, photos, audio, and location.'),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create a new memory'),
                onTap: () => context.push('/entry'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Open map'),
                onTap: () => context.push('/map'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/entry'),
        child: const Icon(Icons.add),
      ),
    );
  }
}