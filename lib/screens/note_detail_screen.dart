import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';

// helper function buat convert string ke Color
Color _getColorFromHex(String color) {
  try {
    String hexColor = color.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // tambahin alpha
    } else if (hexColor.length == 8) {
      // udah ada alpha
    } else {
      // kalau format salah
      return Colors.grey; // fallback color
    }
    return Color(int.parse("0x$hexColor"));
  } catch (e) {
    return Colors.grey; // fallback kalau error
  }
}


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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Note Details'),
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
            Text('Updated: ${_formatDate(currentNote.updatedAt)}'),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Title',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  currentNote.title,
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  currentNote.description,
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentNote.imagePath != null)
              Image.file(File(currentNote.imagePath!)),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // biar kiri
              children: [
                const Text(
                  'Tag:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4), // spasi kecil antar label
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorFromHex(currentNote.color), // convert string ke Color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentNote.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
