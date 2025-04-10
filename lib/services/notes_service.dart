import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_notes/models/note_model.dart';

class NotesService {
  final Box<Note> _notesBox = Hive.box<Note>('notesBox');

  // Get all notes
  List<Note> getAllNotes() {
    return _notesBox.values.toList();
  }

  // Add a note
  Future<void> addNote(Note note) {
    return _notesBox.put(note.id, note);
  }

  // Get a note by ID
  Note? getNote(String id) {
    return _notesBox.get(id);
  }

  // update a note
  Future<void> updateNote(Note note) {
    note.updatedAt = DateTime.now();
    return _notesBox.put(note.id, note);
  }

  // delete a note
  Future<void> deleteNote(String id) {
    return _notesBox.delete(id);
  }
}
