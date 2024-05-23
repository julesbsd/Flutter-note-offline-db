import 'package:flutter/material.dart';
import 'package:offlinedb/models/note.dart';
import 'package:offlinedb/models/note_database.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Text controller
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // on startup read notes
    readNotes();
  }

  //create a note
  void createNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              context.read<NoteDatabase>().addNote(textController.text);
              // clear dialog text
              textController.clear();
              // pop dialog
              Navigator.pop(context);
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }

  // read a notes
  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  // update a note
  void updateNote(Note note) {
    // prefill the current note text
    textController.text = note.text;
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Update Note'),
      content: TextField(controller: textController),
      actions: [
        // update button
        MaterialButton(
          // update in db
          onPressed: () {
            context.read<NoteDatabase>().updateNote(note.id, textController.text);
            // clear controller
            textController.clear();
            // pop dialog 
            Navigator.pop(context);
          },

        child: const Text('Update'),
        )
      ],
    ),
    );
  }

// delete note 
void deleteNote(int id) {
  context.read<NoteDatabase>().deleteNotes(id);
}
  @override
  Widget build(BuildContext context) {
    // note database
    final noteDatabase = context.watch<NoteDatabase>();

    List<Note> currentNotes = noteDatabase.currentNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
          itemCount: currentNotes.length,
          itemBuilder: (context, index) {
            // get individual note
            final note = currentNotes[index];
            return ListTile(
              title: Text(note.text),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // edit button
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      updateNote(note);
                    },
                  ),
                  // delete button,
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteNote(note.id);
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}
