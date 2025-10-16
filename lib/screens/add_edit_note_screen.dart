import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import 'note_preference.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late Note _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note ??
        Note(
          title: '',
          description: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    _titleController.text = _note.title;
    _descriptionController.text = _note.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openPreference() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotePreferenceScreen(
          initialData: _note.toMap(),
          initialLabel: _note.label,
          initialColor: _note.color,
          initialImagePath: _note.imagePath,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _note.label = result['label'];
        _note.color = result['color'];
        _note.imagePath = result['imagePath'];
      });
    }
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      _note.title = _titleController.text.trim();
      _note.description = _descriptionController.text.trim();
      _note.updatedAt = DateTime.now();

      Navigator.pop(context, _note); // kirim Note ke HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  border: InputBorder.none,
                  ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Title can't empty" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi*',
                  border: InputBorder.none,
                  ),
                maxLines: null,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Description can't empty" : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Preference"),
                subtitle: Text("Tag: ${_note.label}, Color: ${_note.color}"),
                trailing: _note.imagePath != null
                    ? Image.file(File(_note.imagePath!), width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.arrow_forward),
                onTap: _openPreference,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
