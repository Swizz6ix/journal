class Journal {
  String id;
  String uid;
  String date;
  String mood;
  String note;

  DateTime lastModified;
  bool isSynced;

  Journal({
    required this.id,
    required this.uid,
    required this.date,
    required this.mood,
    required this.note,
    required this.lastModified,
    required this.isSynced,
  });
  
  Journal.empty()
    : id = '',
      uid = '',
      date = DateTime.now().toIso8601String(),
      mood = '',
      note = '',
      lastModified = DateTime.now(),
      isSynced = false;

  Journal copyWith({
    String? id,
    String? uid,
    String? date,
    String? mood,
    String? note,
    DateTime? lastModified,
    bool? isSynced,
  }) {
    return Journal(
      id: id ?? this.id, 
      uid: uid ?? this.uid, 
      date: date ?? this.date, 
      mood: mood ?? this.mood, 
      note: note ?? this.note,
      lastModified: lastModified ?? this.lastModified,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  void markModified() {
    lastModified = DateTime.now();
    isSynced = false;
  }

  void markSync() {
    isSynced = true;
  }

  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
    id: json['id'] ?? '',
    uid: json['uid'] ?? '', 
    date: json['date'] ?? '', 
    mood: json['mood'] ?? '', 
    note: json['note'] ?? '',
    lastModified: json['lastModified'] != null 
      ? DateTime.parse(json['lastModified']) 
      : DateTime.now(),
    isSynced: json['isSynced'] ?? false,
  );

  factory Journal.fromDoc(dynamic doc) => Journal(
    id: doc.id, 
    uid: doc['uid'] ?? '', 
    date: doc['date'] ?? '', 
    mood: doc['mood'] ?? '', 
    note: doc['note'] ?? '',
    lastModified: doc['lastModified'] != null ? DateTime.parse(doc['lastModified']) : DateTime.now(),
    isSynced: doc['isSynced'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uid": uid,
    "date": date,
    "mood": mood,
    "note": note,
    "lastModified": lastModified.toIso8601String(),
    "isSynced": isSynced,
  };
}