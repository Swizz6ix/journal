import 'package:journal/models/journal.dart';

class JournalEditState {
  final Journal journal;
  final bool isLoading;
  final bool isSaving;

  const JournalEditState({
    required this.journal,
    this.isLoading = false,
    this.isSaving = false,
  });

  JournalEditState copyWith({
    Journal? journal,
    bool? isLoading,
    bool? isSaving,
  }) {
    return JournalEditState(
      journal: journal ?? this.journal,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}