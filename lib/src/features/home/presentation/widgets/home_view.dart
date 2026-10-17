import 'package:banking_app22/src/features/home/repository/card_model.dart';
import 'package:banking_app22/src/features/home/repository/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:u_credit_card/u_credit_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    this.onDragStarted,
    this.onDragEnded,
    this.onDragUpdate,
    this.proximity = 0.0,
  });

  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;
  final Function(DragUpdateDetails)? onDragUpdate;
  final double proximity;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CardModel>>(
      future: HomeRepository.getCards(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(child: Text(snap.error.toString()));
        } else if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(child: Text('Нет доступных карт'));
        } else {
          final cards = snap.data!;
          return SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final karta = cards[i];
                final cardWidget = CreditCardUi(
                  shouldMaskCardNumber: false,
                  cardHolderFullName: karta.holderName,
                  cardNumber: karta.cardNumber,
                  validFrom: '0',
                  validThru: karta.expireDate.toString(),
                  topLeftColor: Colors.blue,
                  doesSupportNfc: true,
                  placeNfcIconAtTheEnd: true,
                  cardType: CardType.debit,
                  cardProviderLogo: const FlutterLogo(),
                  cardProviderLogoPosition: CardProviderLogoPosition.right,
                  showBalance: true,
                  balance: 128.32434343,
                  autoHideBalance: true,
                  enableFlipping: true,
                  cvvNumber: karta.cvv,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LongPressDraggable<CardModel>(
                    data: karta,
                    feedback: Transform.scale(
                      scale: 1.0 - (proximity * 0.8), // Уменьшаем до 20%
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Карта исчезает
                          Opacity(
                            opacity: (1.0 - proximity * 2.0).clamp(0.0, 1.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 48,
                              child: Material(
                                color: Colors.transparent,
                                child: cardWidget,
                              ),
                            ),
                          ),
                          // Мусорный бак появляется
                          Opacity(
                            opacity: (proximity * 2.0 - 0.5).clamp(0.0, 1.0),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.red,
                                size: 80,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    childWhenDragging: Opacity(opacity: 0.0, child: cardWidget),
                    onDragStarted: onDragStarted,
                    onDragEnd: (_) => onDragEnded?.call(),
                    onDragUpdate: onDragUpdate,
                    child: cardWidget,
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
