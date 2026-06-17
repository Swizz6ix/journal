import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/services/data/database.dart';
import 'package:journal/services/data/database_file_routines.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/pages/edit_entry.dart';
import 'package:journal/providers/journal_edit_bloc_provier.dart';
import 'package:journal/repository/journal_repository.dart';
import 'package:journal/widgets/build_list_view_separated.dart';

class Home extends StatefulWidget {
  final String title;
  final JournalRepository repository;

  const Home({
    super.key, 
    required this.title,
    required this.repository,
  });



  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Database database = Database(
    journal: {},
  );
  final dbRoutlines = DatabaseFileRoutines();
  final ValueNotifier<List<Journal>> _journals = ValueNotifier([]);

  Future<List<Journal>> _loadJournals() async {
    final jsonString = await dbRoutlines.readJournals();
    final db = dbRoutlines.databaseFromJson(jsonString);

    database = db;
    final journals = db.journal.values.toList();

    journals.sort((comp1, comp2) 
        => DateTime.parse(comp2.date).compareTo(DateTime.parse(comp1.date)));
    _journals.value = journals;
    

    return journals;
  }

  Future<void> _addOrEditJournal({
    required bool add, 
    required int index, 
    required Journal journal
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalEditBlocProvier(
          journalEditBloc: JournalEditBloc(
            repository: widget.repository,
            initJournal: journal,
            add: add,
          ),
          child: EditEntry(
            add: add, 
            index: index
          ), 
        ),
        fullscreenDialog: true,
      ),
    );
    print("add or edit clicked");

    await _loadJournals();
  }

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.lightGreen.shade800
          ),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: Icon(
              Icons.exit_to_app
            )
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(32.0), 
          child: Container(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightGreen,
                Colors.lightGreen.shade50
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Journal>>(
        valueListenable: _journals,
        builder: (context, journals, _) {
          if (journals.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return BuildListViewSeparated(
            journals: journals,
            addOrEditJournal: _addOrEditJournal,
            onDelete: (id) async {
              final journalToDelete = journals.firstWhere((journal) => journal.uid == id);
              await widget.repository.deleteJournal(journalToDelete);
              await _loadJournals();
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 44.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightGreen.shade50,
                Colors.lightGreen
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        backgroundColor: Colors.lightGreen.shade300,
        child: const Icon(Icons.add),
        onPressed: () {
          _addOrEditJournal(add: true, index: -1, journal: Journal.empty());
        }
      ),
    );
  }
}
