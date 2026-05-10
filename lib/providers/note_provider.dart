import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/database_helper.dart';

class NoteProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  // Load notes từ database
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _dbHelper.getAllNotes();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm note mới
  Future<void> addNote(String title, String content) async {
    final now = DateTime.now();
    final newNote = Note(
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _dbHelper.insertNote(newNote);
    newNote.id = id;
    _notes.insert(0, newNote);
    notifyListeners();

    debugPrint('Note added: ${newNote.title}, ID: $id');
  }

  // Cập nhật note
  Future<void> updateNote(Note note, String newTitle, String newContent) async {
    final updatedNote = note.copyWith(
      title: newTitle,
      content: newContent,
      updatedAt: DateTime.now(),
    );

    await _dbHelper.updateNote(updatedNote);

    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }

    debugPrint('Note updated: ${updatedNote.title}, ID: ${note.id}');
  }

  // Xóa note
  Future<void> deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
    debugPrint('Note deleted, ID: $id');
  }
}