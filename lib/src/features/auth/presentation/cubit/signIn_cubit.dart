import 'package:banking_app22/src/features/auth/presentation/cubit/signIn_state.dart';
import 'package:banking_app22/src/features/auth/repository/signIn_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SigninCubit extends Cubit<SigninState> {
  SigninCubit() : super(const SigninState(status: SigninStatus.initial));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const SigninState(status: SigninStatus.loading));
    try {
      await SigninRepository.login(
        email: email,
        password: password,
      );
      emit(const SigninState(status: SigninStatus.authentificated));
    } on SigninExseption catch (e) {
      emit(SigninState(
        status: SigninStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(const SigninState(
        status: SigninStatus.failure,
        errorMessage: 'Something went wrong!',
      ));
    }
  }
}