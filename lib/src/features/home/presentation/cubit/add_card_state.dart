enum AddCardStatus { initial, loading, failure, success }

class AddCardState {
  final AddCardStatus status;
  final String? errorMessage;

  const AddCardState({required this.status, this.errorMessage});
}