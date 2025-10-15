class Note {
  int? id;
  String title;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  bool isCompleted;
  String? imagePath;
  String label;
  String color;

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.imagePath,
    this.label = 'Umum',
    this.color = '#2196F3',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'image_path': imagePath,
      'label': label,
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? 'No Description',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          map['updated_at'] ?? DateTime.now().millisecondsSinceEpoch),
      isCompleted: (map['is_completed'] ?? 0) == 1,
      imagePath: map['image_path'],
      label: map['label'] ?? 'Umum',
      color: map['color'] ?? '#2196F3',
    );
  }

  @override
  String toString() {
    return 'Note{id: $id, title: $title, isCompleted: $isCompleted}';
  }
}
