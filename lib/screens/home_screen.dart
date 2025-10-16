import 'package:flutter/material.dart';
import 'package:todo_app/core/extension.dart';
import '../models/note.dart';
import '../database/database_helper.dart';
import '../widgets/loading_indicator.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';
import '../widgets/category_chips.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Color _getColorFromHex(String? color) {
  if (color == null || color.isEmpty) return Colors.grey;

  try {
    String hexColor = color.toUpperCase().replaceAll("#", "");

    if (hexColor.startsWith("0X")) {
      return Color(int.parse(hexColor));
    }

    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }

    return Color(int.parse("0x$hexColor"));
  } catch (e) {
    debugPrint("Color parse error: $e");
    return Colors.grey;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _databaseHelper.getNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load notes: $e');
    }
  }

  Future<void> _addOrEditNote({Note? note}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddEditNoteScreen(note: note)),
    );

    if (result != null && result is Note && mounted) {
      if (note == null) {
        final id = await _databaseHelper.insertNote(result);
        result.id = id;
        setState(() => _notes.add(result));
        _showSuccess('✅ Note Created');
      } else {
        await _databaseHelper.updateNote(result);
        setState(() {
          final index = _notes.indexWhere((n) => n.id == result.id);
          if (index != -1) _notes[index] = result;
        });
        _showSuccess('✅ Note Updated');
      }
    }
  }

  Future<void> _deleteAllNotes() async {
    if (_notes.isEmpty) {
      _showError("There are no notes to delete");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete All Notes?", style: TextStyle(color: Colors.red)),
        content: const Text("This action cannot be undone!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseHelper.deleteAllNotes();
        setState(() => _notes.clear());
        _showSuccess("🗑️ All notes deleted successfully");
      } catch (e) {
        _showError("Failed to delete all notes: $e");
      }
    }
  }

  Future<void> _viewNote(Note note) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );

    if (result != null && result is String) {
      if (result == 'edit') {
        _addOrEditNote(note: note);
      } else if (result == 'deleted') {
        setState(() => _notes.removeWhere((n) => n.id == note.id));
        _showSuccess('🗑️ Note "${note.title}" deleted');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: context.color.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text(
          'Noted',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.color.secondary,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete All Notes',
            onPressed: _deleteAllNotes,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            tooltip: 'Refresh',
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('No notes yet'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CategoryChips(),
                    Expanded(
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        padding: const EdgeInsets.all(12),
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return GestureDetector(
                            onTap: () => _viewNote(note),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getColorFromHex(note.color).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    note.description,
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      note.updatedAt.toLocal().toString().split(' ')[0],
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        backgroundColor: context.color.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
