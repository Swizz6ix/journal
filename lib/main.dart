import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:journal/services/data/database_file_routines.dart';
import 'package:journal/firebase_options.dart';
import 'package:journal/pages/home.dart';
import 'package:journal/repository/journal_repository.dart';
import 'package:journal/repository/journal_repository_impl.dart';
import 'package:journal/services/data/db_firebase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final repository = JournalRepositoryImpl(
    firebase: DbFirebase(), 
    localDb: DatabaseFileRoutines(),
  );
  runApp(
    MyApp(repository: repository),
  );
}

class MyApp extends StatelessWidget {
  final JournalRepository repository;

  const MyApp({
    super.key,
    required this.repository,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.lightGreen,
        canvasColor: Colors.lightGreen,
        bottomAppBarTheme: BottomAppBarThemeData(
          color: Colors.lightGreen,
        ),
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Home(
        title: 'Journal',
        repository: repository,
      ),
    );
  }
}
