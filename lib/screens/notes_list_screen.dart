import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_notes/config/app_theme.dart';
import 'package:hive_notes/models/note_model.dart';
import 'package:hive_notes/screens/note_edit_screen.dart';
import 'package:hive_notes/services/notes_service.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService();
  final _uuid = Uuid();

  void _createNewNote() async {
    final newNote = Note(
      id: _uuid.v4(),
      title: '',
      content: '',
      createdAt: DateTime.now(),
    );

    //  Navigate to the note editor screen
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen(note: newNote, isNew: true)),
    );
  }

  void _editNote(Note note) async {
    // Navigate to the note editor screen
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen(note: note, isNew: false)),
    );
  }

  void _deleteNote(String id) async {
    final confirmed = await showDialog<bool>(
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final noteDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (noteDate == today) {
      return 'Today, ${DateFormat.jm().format(dateTime)}';
    } else if (noteDate == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(dateTime)}';
    } else {
      return DateFormat.yMMMd().format(dateTime);
    }
  }

  // Get a color for the note
  Color _getNoteColor(String id) {
    final index = id.hashCode % AppTheme.noteColors.length;
    return AppTheme.noteColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Note>('notesBox').listenable(),
        builder: (context, Box<Note> box, _) {
          // Get all notes directly from the box
          final notes = box.values.toList();

          // Sort notes in the builder
          notes.sort((a, b) {
            final aDate = a.updatedAt ?? a.createdAt;
            final bDate = b.updatedAt ?? b.createdAt;
            return bDate.compareTo(aDate); // newest first
          });

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withAlpha(127),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet. Tap + to add one.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Show notes in a grid
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final displayDate =
                    note.updatedAt != null
                        ? _formatDate(note.updatedAt!)
                        : _formatDate(note.createdAt);

                return GestureDetector(
                  onTap: () => _editNote(note),
                  child: Card(
                    color: _getNoteColor(note.id),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  note.title.isEmpty ? 'Untitled Note' : note.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () => _deleteNote(note.id),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              note.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withAlpha(179),
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayDate,
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
