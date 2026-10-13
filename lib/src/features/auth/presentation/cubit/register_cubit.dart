import 'dart:io';

import 'package:banking_app22/src/features/auth/presentation/cubit/register_state.dart';
import 'package:banking_app22/src/features/auth/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState(status: RegisterStatus.initial));

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    File? avatar,
  }) async {
    emit(const RegisterState(status: RegisterStatus.loading));
    try {
      await AuthRepository.register(
        email: email,
        username: username,
        password: password,
        avatar: avatar,
      );
      emit(const RegisterState(status: RegisterStatus.authentificated));
    } on AuthException catch (e) {
      emit(RegisterState(
        status: RegisterStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(const RegisterState(
        status: RegisterStatus.failure,
        errorMessage: 'Something went wrong!',
      ));
    }
  }
}