import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:flutter/material.dart';

class CardPreview extends StatelessWidget {
  const CardPreview({
    super.key,
    required this.name,
    required this.number,
    required this.expiry,
  });

  final TextEditingController name;
  final TextEditingController number;
  final TextEditingController expiry;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([name, number, expiry]),
      builder: (_, __) => _CardFace(
        holder: name.text,
        number: number.text,
        expiry: expiry.text,
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.holder,
    required this.number,
    required this.expiry,
  });

  final String holder;
  final String number;
  final String expiry;

  String get _brand {
    if (number.startsWith('4')) return 'VISA';
    if (number.startsWith('5') || number.startsWith('2')) return 'MASTERCARD';
    return '';
  }

  String get _numberText {
    final padded = number.replaceAll(' ', '').padRight(16, '•');
    return [
      for (var i = 0; i < 16; i += 4) padded.substring(i, i + 4),
    ].join('  ');
  }

  TextStyle get _caption => TextStyle(
    fontSize: 10,
    letterSpacing: 1,
    color: AppColors.white.withValues(alpha: 0.65),
  );

  static const _value = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.card, AppColors.indigo],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _brand,
                    key: ValueKey(_brand),
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _numberText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CARD HOLDER', style: _caption),
                      const SizedBox(height: 4),
                      Text(
                        holder.trim().isEmpty
                            ? 'YOUR NAME'
                            : holder.trim().toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _value,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EXPIRES', style: _caption),
                    const SizedBox(height: 4),
                    Text(expiry.isEmpty ? 'MM/YY' : expiry, style: _value),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}