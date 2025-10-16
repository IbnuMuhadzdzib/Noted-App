import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/text_formatter.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final Function(Note) onTap;
  final Function(Note) onDelete;
  final Function(Note, bool) onToggleComplete;

  const NoteList({
    super.key,
    required this.notes,
    required this.onTap,
    required this.onDelete,
    required this.onToggleComplete,
  });

    static const Map<String, Color> _colorMap = {
    "Red": Colors.red,
    "Blue": Colors.blue,
    "Green": Colors.green,
    "Yellow": Colors.yellow,
    "Purple": Colors.purple,
    "Orange": Colors.orange,
    "Grey": Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada catatan',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Tap + untuk menambah catatan baru',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteItem(context, note);
      },
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note) {
    return Dismissible(
      key: Key(note.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text('Hapus catatan ini?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete(note);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note Deleted')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: _getColorFromHex(note.color).withOpacity(0.08),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          dense: true,
          leading: Transform.scale(
            scale: 1.4,
            child: Checkbox(
              value: note.isCompleted,
              onChanged: (value) => onToggleComplete(note, value!),
              activeColor: Colors.green,
              checkColor: Colors.white,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                    decoration: note.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getColorFromHex(note.color),
                  borderRadius: BorderRadius.circular(16),
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
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Formatted description
                Container(
                  constraints: const BoxConstraints(maxHeight: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildFormattedDescription(
                        note.description,
                        isCompleted: note.isCompleted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (note.imagePath != null)
                  Row(
                    children: [
                      const Icon(Icons.image, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        'Picture',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Created: ${_formatDate(note.createdAt)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.update, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Updated: ${_formatDate(note.updatedAt)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: SizedBox(
            width: 60,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Status Icon
                Icon(
                  note.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: note.isCompleted ? Colors.green : Colors.grey[500],
                  size: 18,
                ),
                const SizedBox(width: 6),
                // Delete Button
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(context, note),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () => onTap(note),
        ),
      ),
    );
  }

  Color _getColorFromHex(String color) {
  // Kalau dia HEX valid
  if (color.startsWith("#")) {
    String hexColor = color.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // tambahin alpha
    }
    return Color(int.parse("0x$hexColor"));
  }

  // Kalau dia nama warna
  return _colorMap[color] ?? Colors.grey; // fallback ke grey
}


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'You sure wanna delete it?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you really sure want to delete this note? Really??',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be refused.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete(note);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The "${note.title}" deleted',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildFormattedDescription(String description,
      {bool isCompleted = false}) {
    // Jika description terlalu panjang untuk preview, potong dan tampilkan sederhana
    if (description.length > 120) {
      final truncatedText = description.substring(0, 117) + '...';
      return [
        Text(
          truncatedText,
          style: TextStyle(
            decoration:
                isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            fontSize: 14,
            color: Colors.black87,
            height: 1.3,
            fontWeight: FontWeight.w400,
          ),
        ),
      ];
    }

    // Gunakan TextFormatter untuk format lengkap jika tidak terlalu panjang
    final formattedWidgets = TextFormatter.buildFormattedText(
      description,
      baseStyle: TextStyle(
        decoration:
            isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
        fontSize: 14,
        color: Colors.black87,
        height: 1.3,
        fontWeight: FontWeight.w400,
      ),
    );

    // Batasi jumlah widget yang ditampilkan untuk preview
    if (formattedWidgets.length > 3) {
      return [
        ...formattedWidgets.take(2),
        const Text(
          '...',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 17,
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }

    return formattedWidgets;
  }
}
