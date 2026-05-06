import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/memory_entry.dart';
import 'memory_form_controller.dart';

class AddMemoryScreen extends ConsumerStatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  ConsumerState<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagsController = TextEditingController();

  int? _moodScore;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Memory')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _moodScore,
              items: const [1, 2, 3, 4, 5]
                  .map((m) => DropdownMenuItem(value: m, child: Text('Mood $m')))
                  .toList(),
              onChanged: (value) => setState(() => _moodScore = value),
              decoration: const InputDecoration(labelText: 'Mood'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveMemory,
              child: const Text('Save Memory'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMemory() {
    if (_titleController.text.trim().isEmpty) return;

    final repo = ref.read(memoryRepositoryProvider);

    final entry = MemoryEntry()
      ..title = _titleController.text.trim()
      ..bodyText = _bodyController.text.trim()
      ..createdAt = DateTime.now()
      ..moodScore = _moodScore
      ..tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

    repo.saveMemory(entry);

    if (mounted) {
      ref.invalidate(memoriesProvider);
      context.go('/');
    }
  }
}