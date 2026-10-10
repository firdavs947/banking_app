import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/home/presentation/screens/edit_card_screen.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/snackbaar.dart';
import 'package:banking_app22/src/features/home/repository/card_model.dart';
import 'package:banking_app22/src/features/home/repository/card_repository.dart';
import 'package:banking_app22/src/features/home/repository/home_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:u_credit_card/u_credit_card.dart';

class AllCardsScreen extends StatefulWidget {
  const AllCardsScreen({super.key, this.onEdited});

  final VoidCallback? onEdited;

  @override
  State<AllCardsScreen> createState() => _AllCardsScreenState();
}

class _AllCardsScreenState extends State<AllCardsScreen> {
  late Future<List<CardModel>> _future = HomeRepository.getCards();

  void _reload() {
    setState(() {
      _future = HomeRepository.getCards();
    });
  }

  Future<void> _edit(CardModel karta) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditCardScreen(card: karta)),
    );
    if (updated == true && mounted) widget.onEdited?.call();
  }

  Future<void> _delete(CardModel karta) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete this card?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    print('deleting card documentId: ${karta.documentID}');

    try {
      await CardRepository.deleteCard(documentId: karta.documentID);
      if (!mounted) return;
      showTopSnackBar(context, 'Card deleted', isError: false);
      _reload();
    } on AddCardException catch (e) {
      if (!mounted) return;
      showTopSnackBar(context, e.message);
        } catch (e) {
      print('delete error: $e');
      if (!mounted) return;
      showTopSnackBar(context, 'Something went wrong!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.8,
                child: FutureBuilder(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(child: CircularProgressIndicator()),
                        ],
                      );
                    } else if (snap.hasError) {
                      return Center(child: Text(snap.error.toString()));
                    } else if (!snap.hasData || (snap.data as List).isEmpty) {
                      return const Center(child: Text('Нет доступных карт'));
                    } else {
                      final cards = snap.data!;
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: ListView.builder(
                          itemCount: cards.length,
                          itemBuilder: (context, i) {
                            final karta = cards[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 30),
                                  CreditCardUi(
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
                                    cardProviderLogoPosition:
                                        CardProviderLogoPosition.right,
                                    showBalance: true,
                                    balance: 128.32434343,
                                    autoHideBalance: true,
                                    enableFlipping: true,
                                    cvvNumber: karta.cvv,
                                  ),
                                  SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 60,
                                    ),
                                    child: Row(
                                      spacing: 10,
                                      children: [
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () => _edit(karta),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                    AppColors.blue,
                                                  ),
                                            ),
                                            child: Row(
                                              spacing: 20,
                                              children: [
                                                Icon(CupertinoIcons.pen),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () => _delete(karta),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                    AppColors.red,
                                                  ),
                                            ),
                                            child: Row(
                                              spacing: 20,
                                              children: [
                                                Icon(CupertinoIcons.delete),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}