import 'package:journal/models/journal.dart';

abstract class DbFirebaseApi {
  Stream<List<Journal>> getJournalList(String uid);
  Future<Journal> getJournal(String documentID);
  Future<Journal> addJournal(Journal journal);
  Future<void> updateJournal(Journal journal);
  Future<void> updateJournalWithTransaction(Journal journal);
  Future<void> deleteJournal(Journal journal);
}