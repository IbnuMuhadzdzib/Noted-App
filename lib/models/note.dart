import 'dart:convert';

import 'package:flutter/material.dart';

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
  bool isTodo;
  List<String>? todoItems;
  List<bool>? todoCompleted;

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.imagePath,
    this.label = 'General',
    this.color = '#2196F3',
    this.isTodo = false,
    this.todoItems,
    this.todoCompleted,
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
      'is_todo': isTodo ? 1 : 0,
      'todo_items': todoItems != null ? jsonEncode(todoItems) : null,
      'todo_completed':
          todoCompleted != null ? jsonEncode(todoCompleted) : null,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
      debugPrint('🧩 Raw note map: $map'); // <-- ini buat liat isi datanya

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
    label: map['label'] ?? 'General',
    color: map['color'] ?? '#2196F3',
    isTodo: (map['is_todo'] ?? 0) == 1,
    todoItems: (map['todo_items'] != null)
        ? List<String>.from(jsonDecode(map['todo_items']))
        : [],
    todoCompleted: (map['todo_completed'] != null)
        ? List<bool>.from(jsonDecode(map['todo_completed']))
        : [],
  );
}


  @override
  String toString() {
    return 'Note{id: $id, title: $title, isTodo: $isTodo, isCompleted: $isCompleted, todos: ${todoItems?.length ?? 0}}';
  }
}
