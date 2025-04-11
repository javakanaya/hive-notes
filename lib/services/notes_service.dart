import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_notes/models/note_model.dart';

class NotesService {
  final Box<Note> _notesBox = Hive.box<Note>('notesBox');

  // Get all notes with error handling
  List<Note> getAllNotes() {
    try {
      return _notesBox.values.toList();
    } catch (e) {
      print('Error retrieving notes: $e');
      return []; // Return empty list on error
    }
  }

  // Add a note with error handling
  Future<void> addNote(Note note) async {
    try {
      return await _notesBox.put(note.id, note);
    } catch (e) {
      print('Error adding note: $e');
      throw Exception('Failed to add note: $e');
    }
  }

  // Get a note by ID with error handling
  Note? getNote(String id) {
    try {
      return _notesBox.get(id);
    } catch (e) {
      print('Error retrieving note $id: $e');
      return null;
    }
  }

  // Update a note with error handling
  Future<void> updateNote(Note note) async {
    try {
      note.updatedAt = DateTime.now();
      return await _notesBox.put(note.id, note);
    } catch (e) {
      print('Error updating note: $e');
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note with error handling
  Future<void> deleteNote(String id) async {
    try {
      return await _notesBox.delete(id);
    } catch (e) {
      print('Error deleting note: $e');
      throw Exception('Failed to delete note: $e');
    }
  }
}
