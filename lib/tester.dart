// // import 'package:flutter/material.dart';
// // import 'package:my_app/add_new_card.dart';
// // import 'package:my_app/database.dart';
// // import 'package:encrypt/encrypt.dart' as encrypt;
// // import 'package:flutter_credit_card/flutter_credit_card.dart';
// // import 'env.dart' as env;

// // class Tester extends StatefulWidget {
// //   static const routeName = '/TestPage';
// //   const Tester({super.key});

// //   @override
// //   State<Tester> createState() => _TesterState();
// // }

// // class _TesterState extends State<Tester> {
// //   List<Map<String, dynamic>> _cards = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCards();
// //   }

// //   Future<void> _loadCards() async {
// //     final cards = await EncryptousHelper.instance.queryAllRows();
// //     setState(() {
// //       _cards = cards;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Encryptous'),
// //       ),
// //       body: _cards.isEmpty
// //           ? const Center(
// //               child: Text('No cards found'),
// //             )
// //           : ListView.builder(
// //               itemCount: _cards.length,
// //               itemBuilder: (context, index) {
// //                 print(index);
// //                 final card = _cards[index];
// //                 final key = encrypt.Key.fromUtf8(env.aes_private_key);
// //                 final iv = encrypt.IV.fromLength(16);
// //                 final encrypter = encrypt.Encrypter(encrypt.AES(key));
// //                 final cardNumber =
// //                     encrypter.decrypt64(card['card_number'], iv: iv);
// //                 final expiryDate =
// //                     encrypter.decrypt64(card['expiry_date'], iv: iv);
// //                 final cardHolderName =
// //                     encrypter.decrypt64(card['card_holder_name'], iv: iv);
// //                 final cvvCode = encrypter.decrypt64(card['cvv_code'], iv: iv);

// //                 return Padding(
// //                   padding: const EdgeInsets.symmetric(vertical: 8.0),
// //                   child: CreditCardWidget(
// //                     cardNumber: cardNumber,
// //                     expiryDate: expiryDate,
// //                     cardHolderName: cardHolderName,
// //                     cvvCode: cvvCode,
// //                     showBackView: false,
// //                     onCreditCardWidgetChange: (CreditCardBrand) {},
// //                   ),
// //                 );
// //               },
// //             ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () {
// //           Navigator.pushNamed(context, NewCardPage.routeName).then((_) {
// //             _loadCards();
// //           });
// //         },
// //         child: const Icon(Icons.add),
// //       ),
// //     );
// //   }
// // }


// //  /*ElevatedButton(
// //               onPressed: () async {
// //                 final rows = await EncryptousHelper.instance.queryAllRows();
// //                 final key = encrypt.Key.fromUtf8(
// //                     env.aes_private_key); // Make this global
// //                 final iv = encrypt.IV.fromLength(16);
// //                 final encrypter = encrypt.Encrypter(encrypt.AES(key));

// //                 for (final row in rows) {
// //                   print(row);
// //                   try {
// //                     final cardNumber =
// //                         encrypter.decrypt64(row['card_number'], iv: iv);
// //                     final expiryDate =
// //                         encrypter.decrypt64(row['expiry_date'], iv: iv);
// //                     final cardHolderName =
// //                         encrypter.decrypt64(row['card_holder_name'], iv: iv);
// //                     final cvvCode =
// //                         encrypter.decrypt64(row['cvv_code'], iv: iv);

// //                     print('Card Number: $cardNumber');
// //                     print('Expiry Date: $expiryDate');
// //                     print('Card Holder Name: $cardHolderName');
// //                     print('CVV Code: $cvvCode');
// //                     print('-------------------');
// //                   } catch (e) {
// //                     final cardNumber = "ERROR: $e";
// //                     final expiryDate = "ERROR: $e";
// //                     final cardHolderName = "ERROR: $e";
// //                     final cvvCode = "ERROR: $e";
// //                     print('Card Number: $cardNumber');
// //                     print('Expiry Date: $expiryDate');
// //                     print('Card Holder Name: $cardHolderName');
// //                     print('CVV Code: $cvvCode');
// //                     print('-------------------');
// //                   }
// //                 }
// //               },
// //               child: const Text('Print all data'),
// //             ),*/



// class _CreditCardFormState extends State<CreditCardForm> {
//   final TextEditingController _cardNumberController = TextEditingController();
//   final TextEditingController _expiryDateController = TextEditingController();
//   final TextEditingController _cvvController = TextEditingController();
//   final TextEditingController _cardHolderNameController =
//       TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _cardNumberController.dispose();
//     _expiryDateController.dispose();
//     _cvvController.dispose();
//     _cardHolderNameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Credit Card Form'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Card Number',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               TextFormField(
//                 controller: _cardNumberController,
//                 keyboardType: TextInputType.number,
//                 maxLength: 16,
//                 validator: (value) {
//                   if (value!.isEmpty || value.length != 16) {
//                     return 'Please Enter Valid Number';
//                   }
//                   return null;
//                 },
//                 decoration: const InputDecoration(
//                   hintText: 'XXXX XXXX XXXX XXXX',
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Expiry Date',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                         TextFormField(
//                           controller: _expiryDateController,
//                           keyboardType: TextInputType.datetime,
//                           maxLength:
//                               5, // changed maxLength from 4 to 5 to include the '/' separator
//                           validator: (value) {
//                             if (value!.isEmpty || value.length != 5) {
//                               return 'Please Enter Valid Number';
//                             }
//                             final monthYear = value.split('/');
//                             if (monthYear.length != 2) {
//                               return 'Please Enter Valid Number';
//                             }
//                             final month = int.tryParse(monthYear[0]);
//                             final year = int.tryParse(monthYear[1]);
//                             if (month == null || year == null) {
//                               return 'Please Enter Valid Number';
//                             }
//                             if (month < 1 || month > 12) {
//                               return 'Please enter a valid month (1-12)';
//                             }
//                             final now = DateTime.now();
//                             final expiryDate =
//                                 DateTime(now.year + year, month, 1);

//                             if (expiryDate.isBefore(now)) {
//                               return 'Card has expired';
//                             }
//                             return null;
//                           },

//                           decoration: const InputDecoration(
//                             hintText: 'MM/YY',
//                           ),
//                           onChanged: (String value) {
//                             if (_expiryDateController.text
//                                 .startsWith(RegExp('[2-9]'))) {
//                               _expiryDateController.text =
//                                   '0${_expiryDateController.text}';
//                               _expiryDateController.selection =
//                                   TextSelection.fromPosition(
//                                 TextPosition(
//                                     offset: _expiryDateController.text.length),
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16.0),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'CVV',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                         TextFormField(
//                           controller: _cvvController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             LengthLimitingTextInputFormatter(4),
//                           ],
//                           decoration: const InputDecoration(
//                             hintText: 'XXX',
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter the CVV';
//                             }
//                             if (value.length < 3 || value.length > 4) {
//                               return 'CVV should be 3 or 4 digits';
//                             }

//                             return null; // return null if input is valid
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16.0),
//               const Text(
//                 'Cardholder Name',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               TextFormField(
//                 controller: _cardHolderNameController,
//                 decoration: const InputDecoration(
//                   hintText: '',
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Process form data
//                     }
//                   },
//                   child: const Text('Submit'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }