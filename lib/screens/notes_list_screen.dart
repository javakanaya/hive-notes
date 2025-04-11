import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_notes/models/note_model.dart';
import 'package:hive_notes/screens/note_edit_screen.dart';
import 'package:hive_notes/services/notes_service.dart';
import 'package:uuid/uuid.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService();
  final _uuid = Uuid();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notes = _notesService.getAllNotes();
      // sort notes by updatedAt or createdAt
      _notes.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt;
        final bDate = b.updatedAt ?? b.createdAt;
        return bDate.compareTo(aDate); // newest first
      });
    });
  }

  void _createNewNote() async {
    final newNote = Note(
      id: _uuid.v4(),
      title: '',
      content: '',
      createdAt: DateTime.now(),
    );

    //  Navigate to the note editor screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen(note: newNote, isNew: true)),
    );

    if (result == true) {
      _refreshNotes();
    }
  }

  void _editNote(Note note) async {
    // Navigate to the note editor screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen(note: note, isNew: false)),
    );

    if (result == true) {
      _refreshNotes();
    }
  }

  void _deleteNote(String id) async {
    final confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
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
          ),
    );

    if (confirmed == true) {
      await _notesService.deleteNote(id);
      _refreshNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Note>('notesBox').listenable(),
        builder: (context, Box<Note> box, _) {
          if (_notes.isEmpty) {
            return Center(
              child: Text(
                'No notes yet. Tap + to add one.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              final note = _notes[index];
              return Text(note.title);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
