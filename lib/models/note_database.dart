import 'package:isar/isar.dart';
import 'package:offlinedb/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class NoteDatabase extends ChangeNotifier{
  static late Isar isar;

  // initialize the database

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema],
      directory: dir.path,
    );
  }

// list of notes
  final List<Note> currentNotes = [];

// CREATING
  Future<void> addNote(String textFromUser) async {
    // create new note object
    final newNote = Note()..text = textFromUser;

    // save to db
    await isar.writeTxn(() => isar.notes.put(newNote));

//reread from db
    fetchNotes();
  }

// Read from db
  Future<void> fetchNotes() async {
    List<Note> fetchNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchNotes);
    notifyListeners();
  }

  // UPDATE 
  Future<void> updateNote(int id, String newText) async {
    final existingNote = await isar.notes.get(id);
    if (existingNote != null) {
      existingNote.text = newText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  // DELETE 
  Future<void> deleteNotes(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}
