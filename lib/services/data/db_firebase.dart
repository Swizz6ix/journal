import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/data/db_firebase_api.dart';

class DbFirebase implements DbFirebaseApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionJournals = 'journals';

  DbFirebase();

  @override
  Stream<List<Journal>> getJournalList(String uid) {
    return _firestore
      .collection(_collectionJournals)
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((QuerySnapshot snapshot) {
        List<Journal> journalDocs = snapshot.docs.map(
          (doc) => Journal.fromDoc(doc)
        ).toList();
        return journalDocs;
      });
  }

  @override
  Future<Journal> getJournal(String documentID) async {
    DocumentSnapshot doc = await _firestore
      .collection(_collectionJournals)
      .doc(documentID)
      .get();
    return Journal.fromDoc(doc);
  }

  @override
  Future<Journal> addJournal(Journal journal) async {
    // Create a new document reference with an auto-generated ID
    DocumentReference documentReference = _firestore
      .collection(_collectionJournals)
      .doc(journal.id);

    // Set the document data with the journal fields
      await documentReference.set({
        'date': journal.date,
        'mood': journal.mood,
        'note': journal.note,
        'uid': journal.uid,
      });

    // Return the journal with the document ID assigned
    return Journal(
      id: documentReference.id, 
      uid: journal.uid, 
      date: journal.date, 
      mood: journal.mood, 
      note: journal.note,
      lastModified: journal.lastModified,
      isSynced: journal.isSynced,
    );
  }

  @override
  Future<void> updateJournal(Journal journal) async {
    await _firestore
      .collection(_collectionJournals)
      .doc(journal.id)
      .update({
        'date': journal.date,
        'mood': journal.mood,
        'note': journal.note,
        'lastModified': journal.lastModified,
        'isSynced': journal.isSynced,
      })
      .catchError((error) => print('Error updating: $error'));
  }

  @override
  Future<void> updateJournalWithTransaction(Journal journal) async {
    DocumentReference docRef = _firestore
      .collection(_collectionJournals)
      .doc(journal.id);

    await _firestore.runTransaction((transactionHandler) async {
      // Read must occur before writes inside a transaction block
      DocumentSnapshot snapshot = await transactionHandler.get(docRef);
      if (snapshot.exists) {
        transactionHandler.update(docRef, {
          'date': journal.date,
          'mood': journal.mood,
          'note': journal.note,
          'lastModified': journal.lastModified,
          'isSynced': journal.isSynced,
        });
      }
    });
  }

  @override
  Future<void> deleteJournal(Journal journal) async {
    await _firestore
      .collection(_collectionJournals)
      .doc(journal.id)
      .delete()
      .catchError((error) => print('Error deleting: $error'));
  }
}