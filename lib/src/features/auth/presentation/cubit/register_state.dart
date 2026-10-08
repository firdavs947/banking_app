enum RegisterStatus { initial, loading, failure, authentificated }

class RegisterState {
  final RegisterStatus status;
  final String? errorMessage;

  const RegisterState({required this.status, this.errorMessage});
}