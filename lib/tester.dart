// import 'package:flutter/material.dart';
// import 'package:my_app/add_new_card.dart';
// import 'package:my_app/database.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'package:flutter_credit_card/flutter_credit_card.dart';
// import 'env.dart' as env;

// class Tester extends StatefulWidget {
//   static const routeName = '/TestPage';
//   const Tester({super.key});

//   @override
//   State<Tester> createState() => _TesterState();
// }

// class _TesterState extends State<Tester> {
//   List<Map<String, dynamic>> _cards = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCards();
//   }

//   Future<void> _loadCards() async {
//     final cards = await EncryptousHelper.instance.queryAllRows();
//     setState(() {
//       _cards = cards;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Encryptous'),
//       ),
//       body: _cards.isEmpty
//           ? const Center(
//               child: Text('No cards found'),
//             )
//           : ListView.builder(
//               itemCount: _cards.length,
//               itemBuilder: (context, index) {
//                 print(index);
//                 final card = _cards[index];
//                 final key = encrypt.Key.fromUtf8(env.aes_private_key);
//                 final iv = encrypt.IV.fromLength(16);
//                 final encrypter = encrypt.Encrypter(encrypt.AES(key));
//                 final cardNumber =
//                     encrypter.decrypt64(card['card_number'], iv: iv);
//                 final expiryDate =
//                     encrypter.decrypt64(card['expiry_date'], iv: iv);
//                 final cardHolderName =
//                     encrypter.decrypt64(card['card_holder_name'], iv: iv);
//                 final cvvCode = encrypter.decrypt64(card['cvv_code'], iv: iv);

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: CreditCardWidget(
//                     cardNumber: cardNumber,
//                     expiryDate: expiryDate,
//                     cardHolderName: cardHolderName,
//                     cvvCode: cvvCode,
//                     showBackView: false,
//                     onCreditCardWidgetChange: (CreditCardBrand) {},
//                   ),
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pushNamed(context, NewCardPage.routeName).then((_) {
//             _loadCards();
//           });
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }


//  /*ElevatedButton(
//               onPressed: () async {
//                 final rows = await EncryptousHelper.instance.queryAllRows();
//                 final key = encrypt.Key.fromUtf8(
//                     env.aes_private_key); // Make this global
//                 final iv = encrypt.IV.fromLength(16);
//                 final encrypter = encrypt.Encrypter(encrypt.AES(key));

//                 for (final row in rows) {
//                   print(row);
//                   try {
//                     final cardNumber =
//                         encrypter.decrypt64(row['card_number'], iv: iv);
//                     final expiryDate =
//                         encrypter.decrypt64(row['expiry_date'], iv: iv);
//                     final cardHolderName =
//                         encrypter.decrypt64(row['card_holder_name'], iv: iv);
//                     final cvvCode =
//                         encrypter.decrypt64(row['cvv_code'], iv: iv);

//                     print('Card Number: $cardNumber');
//                     print('Expiry Date: $expiryDate');
//                     print('Card Holder Name: $cardHolderName');
//                     print('CVV Code: $cvvCode');
//                     print('-------------------');
//                   } catch (e) {
//                     final cardNumber = "ERROR: $e";
//                     final expiryDate = "ERROR: $e";
//                     final cardHolderName = "ERROR: $e";
//                     final cvvCode = "ERROR: $e";
//                     print('Card Number: $cardNumber');
//                     print('Expiry Date: $expiryDate');
//                     print('Card Holder Name: $cardHolderName');
//                     print('CVV Code: $cvvCode');
//                     print('-------------------');
//                   }
//                 }
//               },
//               child: const Text('Print all data'),
//             ),*/
