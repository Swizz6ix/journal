import 'package:journal/models/journal.dart';

abstract class JournalRepository {
  Future<void> addJournal(Journal journal);
  Future<void> updateJournal(Journal journal);
  Stream<List<Journal>> getJournals(String uid);
  Future<void> deleteJournal(Journal journal);
}