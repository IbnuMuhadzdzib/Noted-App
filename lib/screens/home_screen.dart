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

  Future<void> _showConfirmBottomSheet({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          runSpacing: 12,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Text(message, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Delete",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    await _showConfirmBottomSheet(
      title: "Delete Note?",
      message: "Are you sure you want to delete '${note.title}'?",
      onConfirm: () async {
        try {
          await _databaseHelper.deleteNote(note.id!);
          setState(() => _notes.removeWhere((n) => n.id == note.id));
          _showSuccess('🗑️ Note "${note.title}" deleted');
        } catch (e) {
          _showError('Failed to delete note: $e');
        }
      },
    );
  }

  Future<void> _deleteAllNotes() async {
    if (_notes.isEmpty) {
      _showError("There are no notes to delete");
      return;
    }

    await _showConfirmBottomSheet(
      title: "Delete All Notes?",
      message: "This action can't be undone?",
      onConfirm: () async {
        try {
          await _databaseHelper.deleteAllNotes();
          setState(() => _notes.clear());
          _showSuccess('🗑️ All Notes was deleted');
        } catch (e) {
          _showError('Failed to delete note: $e');
        }
      },
    );
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
                                color: _getColorFromHex(note.color)
                                    .withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: _getColorFromHex(note.color),
                                        ),
                                        child: Text(
                                          note.label,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 20, color: Colors.red),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _deleteNote(note),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    note.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                                      note.updatedAt
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: () => _addOrEditNote(),
        backgroundColor: context.color.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
