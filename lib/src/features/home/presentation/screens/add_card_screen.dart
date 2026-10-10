import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/reveal.dart';
import 'package:banking_app22/src/features/home/presentation/cubit/add_card_cubit.dart';
import 'package:banking_app22/src/features/home/presentation/cubit/add_card_state.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/add_card_header.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/card_field.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/card_formatter.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/card_priview.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/card_validators.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/primary_button.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/snackbaar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key, this.onSuccess});
 final VoidCallback? onSuccess;

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

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
    context.read<AddCardCubit>().addCard(
      holder: _name.text.trim(),
      number: _number.text.replaceAll(' ', ''),
      expiry: _expiry.text,
      cvv: _cvv.text
    );
  }

   void _onState(BuildContext context, AddCardState state) {
    if (state.status == AddCardStatus.failure) {
      showTopSnackBar(context, state.errorMessage ?? 'Can not add the card!');
    } else if (state.status == AddCardStatus.success) {
      showTopSnackBar(context, 'Card added', isError: false);
      for (final c in [_name, _number, _expiry, _cvv]) {
        c.clear();
      }
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        widget.onSuccess?.call();
      }
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
      create: (_) => AddCardCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<AddCardCubit, AddCardState>(
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
                      _reveal(0, const AddCardHeader(), dy: 16),
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
                          label: 'Add Card',
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