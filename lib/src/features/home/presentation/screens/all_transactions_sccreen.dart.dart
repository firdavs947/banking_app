import 'package:banking_app22/src/features/home/repository/home_repository.dart';
import 'package:flutter/material.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key}); 

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
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
                  return ListView.builder(
                    itemCount: cards.length, 
                    itemBuilder: (context, i) {
                      final card = cards[i]; 
                      return ListTile(
                        title: Text(card.recipient, style: TextStyle(fontWeight: FontWeight.bold),),
                        subtitle: Text(card.cardType, style: TextStyle(fontWeight: FontWeight.bold),),
                        trailing: Text(card.amount, style: TextStyle(fontSize: 17),),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}