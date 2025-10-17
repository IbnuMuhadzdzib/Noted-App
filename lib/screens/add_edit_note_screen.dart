import 'dart:io';
import 'dart:convert';
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
  final List<TextEditingController> _todoControllers = [];
  late Note _note;
  bool isTodoList = false;

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
    isTodoList = _note.isTodo;

    if (_note.todoItems != null && _note.todoItems!.isNotEmpty) {
      for (var item in _note.todoItems!) {
        _todoControllers.add(TextEditingController(text: item));
      }
    } else {
      _todoControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _todoControllers) {
      controller.dispose();
    }
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
      _note.updatedAt = DateTime.now();
      _note.isTodo = isTodoList;

      if (isTodoList) {
        _note.todoItems = _todoControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
        _note.todoCompleted =
            List.generate(_note.todoItems!.length, (index) => false);
        _note.description = _note.todoItems!.join('\n');
      } else {
        _note.description = _descriptionController.text.trim();
      }

      Navigator.pop(context, _note);
    }
  }

  void _addTodoField() {
    setState(() {
      _todoControllers.add(TextEditingController());
    });
  }

  void _removeTodoField(int index) {
    setState(() {
      _todoControllers.removeAt(index);
    });
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
              Row(
                children: [
                  const Text('To-Do List'),
                  const SizedBox(width: 8),
                  Switch(
                    value: isTodoList,
                    onChanged: (val) => setState(() => isTodoList = val),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  border: InputBorder.none,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Title can't be empty"
                    : null,
              ),
              const SizedBox(height: 16),
              if (!isTodoList)
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? "Description can't be empty"
                      : null,
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < _todoControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _todoControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Task ${i + 1}',
                              ),
                              validator: (val) => val == null ||
                                      val.trim().isEmpty
                                  ? "Task can't be empty"
                                  : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () => _removeTodoField(i),
                          )
                        ],
                      ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addTodoField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Preference"),
                subtitle:
                    Text("Tag: ${_note.label}, Color: ${_note.color}"),
                trailing: _note.imagePath != null
                    ? Image.file(File(_note.imagePath!),
                        width: 40, height: 40, fit: BoxFit.cover)
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
