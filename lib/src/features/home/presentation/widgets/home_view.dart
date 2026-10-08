import 'package:banking_app22/src/features/home/repository/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:u_credit_card/u_credit_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key}); 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: HomeRepository.getCards(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(child: Text(snap.error.toString()));
        } else if (!snap.hasData || (snap.data as List).isEmpty) {
          return const Center(child: Text('Нет доступных карт'));
        } else {
          final cards = snap.data!;
          return SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final karta = cards[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CreditCardUi(
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