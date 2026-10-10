
class CardModel {
  final String cardNumber;
  final String holderName;
  final String cvv;
  final DateTime expireDate;
  final String documentID;
  final String amount;
  final String recipient;
  final String cardType;

  CardModel({
    required this.cardNumber,
    required this.cvv,
    required this.expireDate,
    required this.holderName,
    required this.documentID,
    required this.amount,
    required this.recipient,
    required this.cardType,
  });

  static CardModel fromJson(Map json) => CardModel(
    cardNumber: json['Card_number']?.toString() ?? '',
    cvv: json['CVV']?.toString() ?? '',
    expireDate: DateTime.parse(json['Expire_date']),
    holderName: json['Holder_name']?.toString() ?? '',
    documentID: json['documentId']?.toString() ?? '',
    amount: json['Amount']?.toString() ?? '',
    recipient: json['Recipient']?.toString() ?? '',
    cardType: json['Car_type']?.toString() ?? '',
  );
}
