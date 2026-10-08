enum SigninStatus { initial, loading, failure, authentificated }

class SigninState {
  final SigninStatus status;
  final String? errorMessage;

  const SigninState({required this.status, this.errorMessage});
}