class QuestActionsState {
  const QuestActionsState({
    this.isSubmitting = false,
    this.activeActionKey,
  });

  final bool isSubmitting;
  final String? activeActionKey;

  QuestActionsState copyWith({
    bool? isSubmitting,
    String? activeActionKey,
    bool clearActiveActionKey = false,
  }) {
    return QuestActionsState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      activeActionKey: clearActiveActionKey
          ? null
          : activeActionKey ?? this.activeActionKey,
    );
  }
}
