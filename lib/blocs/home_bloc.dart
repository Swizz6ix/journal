import 'dart:async';

import 'package:journal/models/journal.dart';
import 'package:journal/services/auth/authentication_api.dart';
import 'package:journal/services/data/db_firebase_api.dart';

class HomeBloc {
  final DbFirebaseApi dbFirebaseApi;
  final AuthenticationApi authenticationApi;

  final StreamController<List<Journal>> _journalController = StreamController<List<Journal>>.broadcast();
  Sink<List<Journal>> get _addListJournal => _journalController.sink;
  Stream<List<Journal>> get listJournal => _journalController.stream;

  final StreamController<Journal> _journalDeleteController = StreamController<Journal>.broadcast();
  Sink<Journal> get deleteJournal => _journalDeleteController.sink;

  HomeBloc(this.dbFirebaseApi, this.authenticationApi) {
    _startListeners();
  }

  // This method is responsible for setting up two listeners 
  // to retrieve a list of journal and to delete an individual journal entry
  void _startListeners() {
    // Retrieve Firestore Journal Records as List<Journal> not DocumentSnapdhot
    authenticationApi.getFirebaseAuth().currentUser().then((user) {
      dbFirebaseApi.getJournalList(user.uid).listen((journalDocs) {
        _addListJournal.add(journalDocs);
      });

      _journalDeleteController.stream.listen((journal) {
        dbFirebaseApi.deleteJournal(journal);
      });
    });
  }

  // This method closes the StreamController's stream when they are not needed
  void dispose() {
    _journalController.close();
    _journalDeleteController.close();
  }
}