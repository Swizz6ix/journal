import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/providers/inheritedJournal_edit_bloc.dart';

class JournalEditBlocProvier extends StatefulWidget {
  final JournalEditBloc journalEditBloc;
  final Widget child;

  const JournalEditBlocProvier({
    super.key,
    required this.journalEditBloc,
    required this.child,
  });

  static JournalEditBloc of(BuildContext context) {
    final inherited = context
      .dependOnInheritedWidgetOfExactType<InheritedjournalEditBloc>();

    assert(
      inherited != null,
      'No JournalEditBloc found in context',
    );

    return inherited!.journalEditBloc;
  }

  @override
  State<JournalEditBlocProvier> createState() => _JournalEditBlocProviderState();
}

class _JournalEditBlocProviderState extends State<JournalEditBlocProvier> {
  @override
  void dispose() {
    widget.journalEditBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedjournalEditBloc(
      journalEditBloc: widget.journalEditBloc, 
      child: widget.child,
    );
  }
}