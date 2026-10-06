enum RegisterStatus { initial, loading, failure, authentificated }

class RegisterState {
  final RegisterStatus status;

  const RegisterState({required this.status});
}
