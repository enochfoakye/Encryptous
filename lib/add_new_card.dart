// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_credit_card/flutter_credit_card.dart';
// import 'package:flutter_scan_tools/flutter_scan_tools.dart';
// import 'package:flutter_screen_lock/flutter_screen_lock.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:my_app/passcode.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'database.dart';
// import 'dart:convert';
// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'env.dart' as env;

// class NewCardPage extends StatefulWidget {
//   static const routeName = '/Encryptous/addCard2';
//   const NewCardPage({super.key});
//   @override
//   State<NewCardPage> createState() => _NewCardPageState();
// }

// class _NewCardPageState extends State<NewCardPage> {
// // new variables for form
//   String cardNumber = '';
//   String _cardNumber = '';
//   String expiryDate = '';
//   String cardHolderName = '';
//   String cvvCode = '';
//   bool isCvvFocused = false;
//   TextEditingController _cardNumberController = TextEditingController();
//   TextEditingController _expiryDateController = TextEditingController();
//   TextEditingController _cvvController = TextEditingController();
//   TextEditingController _cardHolderNameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   CardScanResul? _scanResult;
//   String _currentPIN = '';

//   // TextEditingController _ocr = TextEditingController();

//   @override
//   void dispose() {
//     _cardNumberController.dispose();
//     _expiryDateController.dispose();
//     _cvvController.dispose();
//     _cardHolderNameController.dispose();
//     super.dispose();
//   }

//   //Creates function that encrypts user input into form before storing into a databse
//   void savedCardData(String cardNumber, String expiryDate,
//       String cardHolderName, String cvvCode) async {
//     final key = encrypt.Key.fromUtf8(env.aes_private_key);
//     final iv = encrypt.IV.fromLength(16);
//     final encrypter = encrypt.Encrypter(encrypt.AES(key));

//     final row = {
//       'card_number': encrypter.encrypt(cardNumber, iv: iv).base64,
//       'expiry_date': encrypter.encrypt(expiryDate, iv: iv).base64,
//       'card_holder_name': encrypter.encrypt(cardHolderName, iv: iv).base64,
//       'cvv_code': encrypter.encrypt(cvvCode, iv: iv).base64,
//     };
//     final id = await EncryptousHelper.instance.insertCard(row);
//     final allRows = await EncryptousHelper.instance.queryAllRows();
//     print(allRows);
//     print('Card saved with id: $id');
//   }

// // to view credit card changes
//   // void onCreditCardModelChange(CreditCardModel? creditCardModel) {
//   //   print("Credit Card Model Change!");
//   //   setState(() {
//   //     _cardNumberController.text = creditCardModel!.cardNumber;
//   //     // _cardNumber = creditCardModel.cardNumber;
//   //     _expiryDateController.text = creditCardModel.expiryDate;
//   //     _cardHolderNameController.text = creditCardModel.cardHolderName;
//   //     _cvvController.text = creditCardModel.cvvCode;
//   //     isCvvFocused = creditCardModel.isCvvFocused;
//   //   });
//   // }

//   //adds ocr technolology function by awaiting card scan
//   void _startScan() async {
//     CardScanResul? scanResult = await FlutterScanTools.scanCard(context);

//     setState(() {
//       _scanResult = scanResult;
//       _cardNumberController.text = _scanResult!.cardNumber.number;
//     });

//     // onCreditCardModelChange(CreditCardModel(_scanResult!.cardNumber.number,
//     //     expiryDate, cardHolderName, cvvCode, isCvvFocused));
//     print(_scanResult);
//   }

//   Future<void> localAuth(BuildContext context) async {
//     final localAuth = LocalAuthentication();
//     final didAuthenticate = await localAuth.authenticate(
//       localizedReason: 'Please authenticate',
//     );
//     if (didAuthenticate) {
//       Navigator.pop(context);
//       Navigator.pushNamed(context, AuthPage.routeName).then((_) => getPIN());
//     }
//   }

//   Future<void> setPIN(String newPIN) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('current_pin', newPIN);

//     setState(() {
//       _currentPIN = newPIN;
//     });
//   }

//   Future<String?> getPIN() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? currentPIN = prefs.getString('current_pin');

//     setState(() {
//       _currentPIN = currentPIN ?? '';
//     });
//     print("Current PIN: $_currentPIN");
//     return currentPIN;
//   }

//   Future<void> _buildLockScreen(BuildContext context) {
//     return showDialog<void>(
//         context: context,
//         builder: (BuildContext context) {
//           return ScreenLock(
//             correctString: _currentPIN,
//             customizedButtonChild: const Icon(Icons.fingerprint),
//             customizedButtonTap: () async => await localAuth(context),
//             onOpened: () async => await localAuth(context),
//             onUnlocked: () {
//               Navigator.pop(context);
//               Navigator.pushNamed(context, AuthPage.routeName);
//             },
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: const Text('Add New Card'),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           //  height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           //   padding: EdgeInsets.only(
//           //  bottom: MediaQuery.of(context).viewInsets.bottom,
//           // ),
//           child: Column(
//             //   mainAxisAlignment: MainAxisAlignment.center,
//             // crossAxisAlignment: CrossAxisAlignment.end,
//             // mainAxisSize: MainAxisSize.min,

//             //creates the card widget seen at the top of the form
//             children: [
//               CreditCardWidget(
//                 cardNumber: _cardNumberController.text,
//                 expiryDate: _expiryDateController.text,
//                 cardHolderName: _cardHolderNameController.text,
//                 cvvCode: _cvvController.text,
//                 showBackView: isCvvFocused,
//                 isHolderNameVisible: true,
//                 onCreditCardWidgetChange:
//                     (CreditCardBrand) {}, //true when you want to show cvv(back) view
//               ),
//               // creates the form underneath the card widget
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Card Number',
//                         style: TextStyle(fontSize: 16.0),
//                       ),
//                       TextFormField(
//                         controller: _cardNumberController,
//                         keyboardType: TextInputType.number,
//                         maxLength: 16,
//                         onChanged: (value) {
//                           setState((() {
//                             cardNumber = value;
//                           }));
//                         },
//                         validator: (value) {
//                           if (value!.isEmpty || value.length != 16) {
//                             return 'Please Enter Valid Number';
//                           }
//                           return null;
//                         },
//                         decoration: const InputDecoration(
//                           hintText: 'XXXX XXXX XXXX XXXX',
//                         ),
//                       ),
//                       const SizedBox(height: 16.0),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Expiry Date',
//                                   style: TextStyle(fontSize: 16.0),
//                                 ),
//                                 TextFormField(
//                                   controller: _expiryDateController,
//                                   keyboardType: TextInputType.datetime,
//                                   maxLength:
//                                       5, // changed maxLength from 4 to 5 to include the '/' separator
//                                   onChanged: (value) {
//                                     setState((() {
//                                       expiryDate = value;
//                                     }));
//                                   },
//                                   validator: (value) {
//                                     if (value!.isEmpty || value.length != 5) {
//                                       return 'Please Enter Valid Number';
//                                     }
//                                     final monthYear = value.split('/');
//                                     if (monthYear.length != 2) {
//                                       return 'Please Enter Valid Number';
//                                     }
//                                     final month = int.tryParse(monthYear[0]);
//                                     final year = int.tryParse(monthYear[1]);
//                                     if (month == null || year == null) {
//                                       return 'Please Enter Valid Number';
//                                     }
//                                     if (month < 1 || month > 12) {
//                                       return 'Please enter a valid month (1-12)';
//                                     }
//                                     final now = DateTime.now();
//                                     final expiryDate =
//                                         DateTime(now.year + year, month, 1);

//                                     if (expiryDate.isBefore(now)) {
//                                       return 'Card has expired';
//                                     }
//                                     return null;
//                                   },

//                                   decoration: const InputDecoration(
//                                     hintText: 'MM/YY',
//                                   ),
//                                   // onChanged: (String value) {
//                                   //   if (_expiryDateController.text
//                                   //       .startsWith(RegExp('[2-9]'))) {
//                                   //     _expiryDateController.text =
//                                   //         '0${_expiryDateController.text}';
//                                   //     _expiryDateController.selection =
//                                   //         TextSelection.fromPosition(
//                                   //       TextPosition(
//                                   //           offset: _expiryDateController
//                                   //               .text.length),
//                                   //     );
//                                   //   }
//                                   // },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 16.0),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'CVV',
//                                   style: TextStyle(fontSize: 16.0),
//                                 ),
//                                 TextFormField(
//                                   controller: _cvvController,
//                                   keyboardType: TextInputType.number,
//                                   inputFormatters: [
//                                     LengthLimitingTextInputFormatter(4),
//                                   ],
//                                   decoration: const InputDecoration(
//                                     hintText: 'XXX',
//                                   ),
//                                   onChanged: (value) {
//                                     setState((() {
//                                       cvvCode = value;
//                                     }));
//                                   },
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please enter the CVV';
//                                     }
//                                     if (value.length < 3 || value.length > 4) {
//                                       return 'CVV should be 3 or 4 digits';
//                                     }

//                                     return null; // return null if input is valid
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16.0),
//                       const Text(
//                         'Cardholder Name',
//                         style: TextStyle(fontSize: 16.0),
//                       ),
//                       TextFormField(
//                         controller: _cardHolderNameController,
//                         decoration: const InputDecoration(
//                           hintText: '',
//                         ),
//                         onChanged: (value) {
//                           setState((() {
//                             cardHolderName = value;
//                           }));
//                         },
//                       ),

//                       const SizedBox(height: 16.0),

//                       //Button for the ocr functunality
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               _startScan();
//                             },
//                             icon: const Icon(Icons.camera_alt),
//                             iconSize: 40,
//                             color: Colors.blue,
//                           ),
//                           FloatingActionButton.extended(
//                             onPressed: () async {
//                               if (_formKey.currentState!.validate()) {
//                                 print(
//                                     'Card saved: $cardNumber, $expiryDate, $cardHolderName, $cvvCode');

//                                 savedCardData(cardNumber, expiryDate,
//                                     cardHolderName, cvvCode);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text(
//                                           'Card Details saved Succesfully')),
//                                 );
//                                 Navigator.pop(context);
//                               }
//                             },
//                             backgroundColor: Colors.blue,
//                             label: const Text('Save card',
//                                 style: TextStyle(fontSize: 18)),
//                             icon: const Icon(Icons.save),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5),
//                               side: const BorderSide(
//                                   color: Colors.white, width: 2),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// //First Fiunction created to save card  Navigator.pop(context);
// /* void savedCardData(String cardNumber, String expiryDate,
//       String cardHolderName, String cvvCode) async {
//     final row = {
//       'card_number': cardNumber,
//       'expiry_date': expiryDate,
//       'card_holder_name': cardHolderName,
//       'cvv_code': cvvCode,
//     };
//     final id =
//         await EncryptousHelper.instance.insertCard(row); //goes to database
//     final allRows =
//         await EncryptousHelper.instance.queryAllRows(); // prints to console
//     print(allRows);

//     print('Card saved with id: $id'); 
//   }*/
