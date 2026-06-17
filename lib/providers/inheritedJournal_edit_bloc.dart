import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';

class InheritedjournalEditBloc extends InheritedWidget {
  final JournalEditBloc journalEditBloc;

  const InheritedjournalEditBloc({
    super.key,
    required this.journalEditBloc,
    required super.child,
  });

  @override
  bool updateShouldNotify(_) => false;
}