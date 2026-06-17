import 'package:journal/models/journal.dart';

class JournalEdit {
  String action;
  Journal journal;

  JournalEdit({
    required this.action,
    required this.journal
  });
}