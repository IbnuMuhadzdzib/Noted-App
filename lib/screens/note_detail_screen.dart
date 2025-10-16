import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note currentNote;

  @override
  void initState() {
    super.initState();
    currentNote = widget.note;
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedNote = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditNoteScreen(note: currentNote),
                ),
              );

              if (updatedNote != null && updatedNote is Note) {
                setState(() {
                  currentNote = updatedNote;
                });
                // langsung kasih signal ke HomeScreen
                Navigator.pop(context, 'edit');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Navigator.pop(context, 'deleted');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              currentNote.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              currentNote.description,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (currentNote.imagePath != null)
              Image.file(File(currentNote.imagePath!)),
            const SizedBox(height: 16),
            Text('Tag: ${currentNote.label}'),
            Text('Updated: ${_formatDate(currentNote.updatedAt)}'),
          ],
        ),
      ),
    );
  }
}
