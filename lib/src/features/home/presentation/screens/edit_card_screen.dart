import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/reveal.dart';
import 'package:banking_app22/src/features/home/presentation/cubit/add_card_state.dart';
import 'package:banking_app22/src/features/home/presentation/cubit/edit_card_cubit.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/add_card_header.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/card_field.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/card_formatter.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/card_priview.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/card_validators.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/primary_button.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/snackbaar.dart';
import 'package:banking_app22/src/features/home/repository/card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCardScreen extends StatefulWidget {
  const EditCardScreen({super.key, required this.card});
  final CardModel card;

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.card.holderName);
  late final _number = TextEditingController(
    text: _groupNumber(widget.card.cardNumber),
  );
  late final _expiry = TextEditingController(
    text: _toMonthYear(widget.card.expireDate.toString()),
  );
  late final _cvv = TextEditingController(text: widget.card.cvv);
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  static String _groupNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String _toMonthYear(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final mm = date.month.toString().padLeft(2, '0');
    final yy = (date.year % 100).toString().padLeft(2, '0');
    return '$mm/$yy';
  }

  @override
  void dispose() {
    _intro.dispose();
    for (final c in [_name, _number, _expiry, _cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<EditCardCubit>().updateCard(
      documentId: widget.card.documentID,
      holder: _name.text.trim(),
      number: _number.text.replaceAll(' ', ''),
      expiry: _expiry.text,
      cvv: _cvv.text,
    );
  }

  void _onState(BuildContext context, AddCardState state) {
    if (state.status == AddCardStatus.failure) {
      showTopSnackBar(
        context,
        state.errorMessage ?? 'Can not update the card!',
      );
        } else if (state.status == AddCardStatus.success) {
      showTopSnackBar(context, 'Card updated', isError: false);
      Navigator.of(context).pop(true);
    }
  }

  Widget _reveal(
    double begin,
    Widget child, {
    double dy = 24,
    double fromScale = 1.0,
  }) {
    return Reveal(
      animation: _intro,
      begin: begin,
      end: begin + 0.33,
      dy: dy,
      fromScale: fromScale,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditCardCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<EditCardCubit, AddCardState>(
          listener: _onState,
          builder: (context, state) => SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                                          _reveal(
                        0,
                        const AddCardHeader(title: 'Edit Card', showBack: true),
                        dy: 16,
                      ),
                      const SizedBox(height: 28),
                      _reveal(
                        0.1,
                        CardPreview(
                          name: _name,
                          number: _number,
                          expiry: _expiry,
                        ),
                        dy: 40,
                        fromScale: 0.94,
                      ),
                      const SizedBox(height: 32),
                      _reveal(
                        0.25,
                        CardField(
                          label: 'Card Holder',
                          controller: _name,
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.characters,
                          validator: CardValidators.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z .'-]"),
                            ),
                            LengthLimitingTextInputFormatter(26),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _reveal(
                        0.33,
                        CardField(
                          label: 'Card Number',
                          controller: _number,
                          icon: Icons.credit_card_rounded,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: CardValidators.number,
                          inputFormatters: [CardNumberFormatter()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _reveal(
                        0.41,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CardField(
                                label: 'Expiry Date',
                                controller: _expiry,
                                icon: Icons.calendar_today_rounded,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: CardValidators.expiry,
                                inputFormatters: [ExpiryFormatter()],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: CardField(
                                label: 'CVV',
                                controller: _cvv,
                                icon: Icons.lock_outline_rounded,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                obscureText: true,
                                validator: CardValidators.cvv,
                                onSubmitted: (_) => _submit(context),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      _reveal(
                        0.52,
                        PrimaryButton(
                          label: 'Save Changes',
                          loading: state.status == AddCardStatus.loading,
                          onPressed: () => _submit(context),
                        ),
                        fromScale: 0.95,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}