import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NotePreferenceScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final String initialLabel;
  final String initialColor;
  final String? initialImagePath;

  const NotePreferenceScreen({
    super.key,
    required this.initialData,
    required this.initialLabel,
    required this.initialColor,
    this.initialImagePath,
  });

  @override
  State<NotePreferenceScreen> createState() => _NotePreferenceScreenState();
}

class _NotePreferenceScreenState extends State<NotePreferenceScreen> {
  late String _selectedLabel;
  late String _selectedColor;
  String? _imagePath;

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

  final Map<String, String> _colors = {
    'Blue': '#2196F3',
    'Green': '#4CAF50',
    'Orange': '#FF9800',
    'Red': '#F44336',
    'Purple': '#9C27B0',
  };

  @override
  void initState() {
    super.initState();
    _selectedLabel =
        _labels.contains(widget.initialLabel) ? widget.initialLabel : _labels.first;
    _selectedColor =
        _colors.containsValue(widget.initialColor) ? widget.initialColor : _colors.values.first;
    _imagePath = widget.initialImagePath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  void _savePreference() {
    final finalResult = Map<String, dynamic>.from(widget.initialData);
    finalResult['label'] = _selectedLabel;
    finalResult['color'] = _selectedColor;
    finalResult['imagePath'] = _imagePath;

    Navigator.of(context).pop(finalResult);
  }

  Color _hexToColor(String hex) {
    return Color(int.parse('FF${hex.substring(1)}', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Note Preferences"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _savePreference)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedLabel,
              decoration: const InputDecoration(labelText: "Label"),
              items: _labels.map((label) => DropdownMenuItem(
                value: label,
                child: Text(label),
              )).toList(),
              onChanged: (val) => setState(() => _selectedLabel = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedColor,
              decoration: const InputDecoration(labelText: "Color"),
              items: _colors.entries.map((e) => DropdownMenuItem(
                value: e.value,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _hexToColor(e.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(e.key),
                  ],
                ),
              )).toList(),
              onChanged: (val) => setState(() => _selectedColor = val!),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text("Picture"),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _pickImage,
                    ),
                  ),
                  if (_imagePath != null) ...[
                    Image.file(File(_imagePath!), height: 100, fit: BoxFit.cover),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text("Hapus", style: TextStyle(color: Colors.red)),
                      onPressed: _removeImage,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
