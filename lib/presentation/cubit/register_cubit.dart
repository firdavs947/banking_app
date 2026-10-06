import 'package:banking_app22/presentation/cubit/register_state.dart';
import 'package:banking_app22/presentation/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState(status: RegisterStatus.initial));

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(RegisterState(status: RegisterStatus.loading));
    try {
      await AuthRepository.register(
        email: email,
        username: username,
        password: password,
      );
      emit(RegisterState(status: RegisterStatus.authentificated));
    } catch (e) {
          emit(RegisterState(status: RegisterStatus.failure));
    }
  }
}
