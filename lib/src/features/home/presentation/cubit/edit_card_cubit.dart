import 'package:banking_app22/src/features/home/presentation/cubit/add_card_state.dart';
import 'package:banking_app22/src/features/home/repository/card_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCardCubit extends Cubit<AddCardState> {
  EditCardCubit() : super(const AddCardState(status: AddCardStatus.initial));

  Future<void> updateCard({
    required String documentId,
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
  }) async {
    emit(const AddCardState(status: AddCardStatus.loading));
    try {
      await CardRepository.updateCard(
        documentId: documentId,
        holder: holder,
        number: number,
        expiry: expiry,
        cvv: cvv,
      );
      emit(const AddCardState(status: AddCardStatus.success));
    } on AddCardException catch (e) {
      emit(AddCardState(
        status: AddCardStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(const AddCardState(
        status: AddCardStatus.failure,
        errorMessage: 'Something went wrong!',
      ));
    }
  }
}