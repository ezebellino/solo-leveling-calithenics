class QuestActionsState {
  const QuestActionsState({
    this.isSubmitting = false,
    this.activeActionKey,
    this.lastCompletedActionKey,
    this.lastErrorCode,
    this.lastErrorMessage,
    this.didRollback = false,
  });

  final bool isSubmitting;
  final String? activeActionKey;
  final String? lastCompletedActionKey;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final bool didRollback;

  bool get hasError => lastErrorMessage != null;

  QuestActionsState copyWith({
    bool? isSubmitting,
    String? activeActionKey,
    String? lastCompletedActionKey,
    String? lastErrorCode,
    String? lastErrorMessage,
    bool? didRollback,
    bool clearActiveActionKey = false,
    bool clearCompletedActionKey = false,
    bool clearError = false,
  }) {
    return QuestActionsState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      activeActionKey: clearActiveActionKey
          ? null
          : activeActionKey ?? this.activeActionKey,
      lastCompletedActionKey: clearCompletedActionKey
          ? null
          : lastCompletedActionKey ?? this.lastCompletedActionKey,
      lastErrorCode: clearError ? null : lastErrorCode ?? this.lastErrorCode,
      lastErrorMessage: clearError
          ? null
          : lastErrorMessage ?? this.lastErrorMessage,
      didRollback: didRollback ?? this.didRollback,
    );
  }
}
