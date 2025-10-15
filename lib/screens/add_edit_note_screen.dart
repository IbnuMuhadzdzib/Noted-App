import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../utils/text_formatter.dart';

import '../core/extension.dart';

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

  String _selectedLabel = 'Umum';
  String _selectedColor = '#2196F3';
  String? _imagePath;
  String _previousText = '';

  final List<String> _labels = [
    'General',
    'Job',
    'Personal',
    'Groceries',
    'Health',
    'Password',
    'Important',
    'Daily',
    'Schedule'
  ];
  final Map<String, Color> _colors = {
    '#2196F3': Colors.blue,
    '#4CAF50': Colors.green,
    '#FF9800': Colors.orange,
    '#F44336': Colors.red,
    '#9C27B0': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _selectedLabel = widget.note!.label;
      _selectedColor = widget.note!.color;
      _imagePath = widget.note!.imagePath;
    }
    _previousText = _descriptionController.text;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
        print('🖼️ Image selected: $_imagePath');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      _showError('Gagal memilih gambar');
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
    print('🖼️ Image removed');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'label': _selectedLabel,
        'color': _selectedColor,
        'imagePath': _imagePath,
      };

      print('💾 Saving note data:');
      print('  Title: ${result['title']}');
      print('  Description: ${result['description']}');
      print('  Label: ${result['label']}');
      print('  Color: ${result['color']}');
      print('  Image: ${result['imagePath']}');

      Navigator.of(context).pop(result);
    }
  }

  // Formatting methods
  void _addChecklistItem(bool checked) {
    final cursorPosition = _descriptionController.selection.baseOffset;
    final currentText = _descriptionController.text;

    final newText = TextFormatter.addChecklistItem(currentText, cursorPosition,
        checked: checked);

    _descriptionController.text = newText;

    // Set cursor position after the new checklist item
    final newCursorPosition = TextFormatter.getNewCursorPosition(
        currentText, newText, cursorPosition);
    _descriptionController.selection =
        TextSelection.fromPosition(TextPosition(offset: newCursorPosition));
  }

  void _addNumberedItem() {
    final cursorPosition = _descriptionController.selection.baseOffset;
    final currentText = _descriptionController.text;

    final newText = TextFormatter.addNumberedItem(currentText, cursorPosition);

    _descriptionController.text = newText;

    // Set cursor position after the new numbered item
    final newCursorPosition = TextFormatter.getNewCursorPosition(
        currentText, newText, cursorPosition);
    _descriptionController.selection =
        TextSelection.fromPosition(TextPosition(offset: newCursorPosition));
  }

  void _toggleChecklistItem() {
    final cursorPosition = _descriptionController.selection.baseOffset;
    final currentText = _descriptionController.text;

    final newText =
        TextFormatter.toggleChecklistAtCursor(currentText, cursorPosition);

    _descriptionController.text = newText;

    // Maintain cursor position
    _descriptionController.selection =
        TextSelection.fromPosition(TextPosition(offset: cursorPosition));
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  void _handleTextChange(String newValue) {
    // Check jika ada enter yang baru ditambahkan
    if (newValue.length > _previousText.length &&
        newValue.contains('\n') &&
        newValue.endsWith('\n')) {
      final cursorPosition = _descriptionController.selection.baseOffset;

      // Handle auto-continuation untuk numbered list dan checklist
      final result = TextFormatter.handleEnterPress(newValue, cursorPosition);

      if (result['shouldUpdate'] == true) {
        final newText = result['newText'] as String;
        final newCursorPos = result['newCursorPosition'] as int;

        _descriptionController.text = newText;
        _descriptionController.selection =
            TextSelection.fromPosition(TextPosition(offset: newCursorPos));

        _previousText = newText;
        return;
      }
    }

    _previousText = newValue;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: context.color.secondary,
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  border: OutlineInputBorder(),
                  hintText: 'Title of ur Notes',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Title can't empty!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field with Formatting Toolbar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formatting Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Text(
                          'Format: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFormatButton(
                          icon: Icons.check_box_outline_blank,
                          tooltip: 'Tambah Checklist',
                          onPressed: () => _addChecklistItem(false),
                        ),
                        const SizedBox(width: 4),
                        _buildFormatButton(
                          icon: Icons.check_box,
                          tooltip: 'Tambah Checklist Tercentang',
                          onPressed: () => _addChecklistItem(true),
                        ),
                        const SizedBox(width: 4),
                        _buildFormatButton(
                          icon: Icons.format_list_numbered,
                          tooltip: 'Tambah Numbered List',
                          onPressed: _addNumberedItem,
                        ),
                        const SizedBox(width: 4),
                        _buildFormatButton(
                          icon: Icons.toggle_on,
                          tooltip: 'Toggle Checklist',
                          onPressed: _toggleChecklistItem,
                        ),
                      ],
                    ),
                  ),
                  // Description TextFormField
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description*',
                      border: OutlineInputBorder(),
                      hintText:
                          'Description goes here',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 8,
                    onChanged: _handleTextChange,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Label Selection
              DropdownButtonFormField<String>(
                value: _selectedLabel,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(),
                ),
                items: _labels.map((String label) {
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLabel = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Color Selection
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: 'Warna',
                  border: OutlineInputBorder(),
                ),
                items: _colors.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: entry.value,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedColor = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Image Picker Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gambar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Pilih dari Gallery'),
                            onPressed: _pickImage,
                          ),
                          const SizedBox(width: 16),
                          if (_imagePath != null)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gambar dipilih',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _imagePath!.split('/').last,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (_imagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Hapus Gambar',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: _removeImage,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isEditing ? 'UPDATE CATATAN' : 'SIMPAN CATATAN',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
