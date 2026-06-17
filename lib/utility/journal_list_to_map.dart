import 'package:journal/models/journal.dart';

Map<String, Journal> journalListToMap(List<Journal> journals) {
  final Map<String, Journal> journalMap = {};
  for (var journal in journals) {
    journalMap[journal.id] = journal;
  }
  return journalMap;
}