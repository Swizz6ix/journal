import 'dart:async';
import 'dart:convert';

import 'package:journal/services/data/database.dart';
import 'package:journal/services/data/database_file_routines.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/repository/journal_repository.dart';
import 'package:journal/services/data/db_firebase.dart';
import 'package:journal/utility/journal_list_to_map.dart';

class JournalRepositoryImpl implements JournalRepository {
  final DbFirebase firebase;
  final DatabaseFileRoutines localDb;

  JournalRepositoryImpl({
    required this.firebase,
    required this.localDb,
  });

  Future<Map<String, Journal>> _readLocalJournalsMap() async {
    final jsonString = await localDb.readJournals();
    final database = localDb.databaseFromJson(jsonString);

    return database.journal;
  }

  Future<void> _writeLocalJournalsMap(Map<String, Journal> journals) async {
    final database = Database(journal: journals);

    await localDb.writeJournals(
      localDb.databaseToJson(database)
    );
  }


  @override
  Stream<List<Journal>> getJournals(String uid) {
    final stream = firebase
      .getJournalList(uid)
      .asyncMap((journals) async {
      await _writeLocalJournalsMap(
        journalListToMap(journals)
      );
      return journals;
    });
    return stream;
  }

  @override
  Future<void> addJournal(Journal journal) async {
    final journals = await _readLocalJournalsMap();

    journal.isSynced = false;
    journal.lastModified = DateTime.now();

    journals[journal.id] = journal;

    print("Adding Journal Locally: ${journal.toJson()}");
    await _writeLocalJournalsMap(journals);
    print("Adding Journal: ${journal.toJson()}");
    print("Local DB After Save: ${journals.length}");

    unawaited(syncFirebase(journal));
  }

  Future<void> syncFirebase(Journal journal) async {
    try {
      print("Syncing journal to Firebase: ${journal.toJson()}");
      await firebase.addJournal(journal);

      journal.markSync();
      print("Successfully synced journal to Firebase: ${journal.toJson()}");

      final journals = await _readLocalJournalsMap();
      journals[journal.id] = journal;
      await _writeLocalJournalsMap(journals);
    } catch (e) {
      await queueJournalForRetry(journal);
      print("Error syncing journal to Firebase: $e");
    }
  }

  Future<void> queueJournalForRetry(Journal journal) async {
    // Implementation for queuing journal for retry
    final file = await localDb.getSyncQueueFile();
    final List<dynamic> raw = await file.exists()
      ? json.decode(await file.readAsString())
      : [];

      raw.add(journal.toJson());
      await file.writeAsString(json.encode(raw));
  }

  @override
  Future<void> updateJournal(Journal journal) async {
    final journals = await _readLocalJournalsMap();
    final existingJournal = journals[journal.id];

    if (existingJournal != null) {
      journal.lastModified = DateTime.now();
      journal.isSynced = false;
      journals[journal.id] = journal;
    }
    await _writeLocalJournalsMap(journals);
      print("Local DB update $journals");

    unawaited(syncUpdate(journal));
    print("firebase update $journals");
  }

  Future<void> syncUpdate(Journal journal) async {
    try {
      print("Syncing updated journal to Firebase: ${journal.toJson()}");
      await firebase.updateJournal(journal);

      journal.markSync();
      print("Successfully synced updated journal to Firebase: ${journal.toJson()}");

      final journals = await _readLocalJournalsMap();
      journals[journal.id] = journal;
      await _writeLocalJournalsMap(journals);
    } catch (e) {
      await queueJournalForRetry(journal);
      print("Error syncing updated journal to Firebase: $e");
    }
  }

  @override
  Future<void> deleteJournal(Journal journal) async {
    final journals = await _readLocalJournalsMap();

    journals.remove(journal.id);
    await _writeLocalJournalsMap(journals);
    unawaited(syncDelete(journal));
  }

  Future<void> syncDelete(Journal journal) async {
    try {
      print("Syncing deleted journal to Firebase: ${journal.toJson()}");
      await firebase.deleteJournal(journal);
      print("Successfully synced deleted journal to Firebase: ${journal.toJson()}");
    } catch (e) {
      await queueJournalForRetry(journal);
      print("Error syncing deleted journal to Firebase: $e");
    }
  }
}