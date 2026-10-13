import 'dart:io';

import 'package:banking_app22/src/features/auth/presentation/cubit/upload_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class UploadCubit extends Cubit<UploadState> {
  UploadCubit() : super( UploadState(status: UploadStatus.initial));

  Future<void> pickImage() async {
    emit( UploadState(status: UploadStatus.loading));
    final picker = ImagePicker();

    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      emit(UploadState(status: UploadStatus.success, image: File(result.path)));
    } else {
      emit( UploadState(status: UploadStatus.initial));
    }
  }
}