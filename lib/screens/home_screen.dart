import 'package:flutter/material.dart';
import 'package:todo_app/core/extension.dart';
import '../models/note.dart';
import '../database/database_helper.dart';
import '../widgets/note_list.dart';
import '../widgets/loading_indicator.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';
import '../widgets/category_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
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
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await _databaseHelper.getNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Gagal memuat catatan: $e');
    }
  }

  Future<void> _addOrEditNote({Note? note}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(note: note),
      ),
    );

    if (result != null && result is Note && mounted) {
      if (note == null) {
        // Tambah note baru
        final id = await _databaseHelper.insertNote(result);
        result.id = id;
        setState(() {
          _notes.add(result);
        });
        _showSuccess('✅ Note Created');
      } else {
        // Edit note
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
      _showError("Tidak ada catatan untuk dihapus");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete All Notes?", style: TextStyle(color: Colors.red),),
        content: const Text("Tindakan ini tidak dapat dibatalkan!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal", style: TextStyle(color: Colors.white),)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus Semua", style: TextStyle(color: Colors.red),)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseHelper.deleteAllNotes();
        setState(() {
          _notes.clear();
        });
        _showSuccess("🗑️ Semua catatan berhasil dihapus");
      } catch (e) {
        _showError("Gagal menghapus semua catatan: $e");
      }
    }
  }

  Future<void> _viewNote(Note note) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );

    if (result != null && result is String) {
      if (result == 'edit') {
        _addOrEditNote(note: note); // langsung edit dari detail
      } else if (result == 'deleted') {
        setState(() {
          _notes.removeWhere((n) => n.id == note.id);
        });
        _showSuccess('🗑️ Catatan "${note.title}" dihapus');
      }
    }
  }

  Future<void> _deleteNote(Note note) async {
    try {
      await _databaseHelper.deleteNote(note.id!);
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
      });
      _showSuccess('🗑️ Note Deleted');
    } catch (e) {
      _showError('Gagal menghapus catatan: $e');
    }
  }

  Future<void> _toggleComplete(Note note, bool isCompleted) async {
    try {
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        description: note.description,
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
        isCompleted: isCompleted,
        imagePath: note.imagePath,
        label: note.label,
        color: note.color,
      );

      await _databaseHelper.updateNote(updatedNote);

      setState(() {
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) _notes[index] = updatedNote;
      });
    } catch (e) {
      _showError('Gagal mengubah status: $e');
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
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            'Noted',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
            onPressed: _loadNotes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CategoryChips(),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : _notes.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_add, size: 80, color: Colors.grey),
                            SizedBox(height: 24),
                            Text(
                              'There is no notes yet',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add a note by tap on the + button below',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotes,
                        child: NoteList(
                          notes: _notes,
                          onTap: _viewNote,
                          onDelete: _deleteNote,
                          onToggleComplete: _toggleComplete,
                        ),
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
