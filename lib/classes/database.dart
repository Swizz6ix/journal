import 'package:journal/classes/journal.dart';

class Database {
  List<Journal> journal;

  Database({required this.journal});

  factory Database.fromJson(Map<String, dynamic> json) => Database(
    journal: json["journals"] == null
      ? []
      : List<Journal>.from(
          json["journals"].map((x) => Journal.fromJson(x))
        )
  );

  Map<String, dynamic> toJson() => {
    "journals": journal.map((x) => x.toJson()).toList(),
  };
}
