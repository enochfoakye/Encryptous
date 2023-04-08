// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_scan_tools/flutter_scan_tools.dart';
import 'database.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'env.dart' as env;

class NewCardPage extends StatefulWidget {
  static const routeName = '/Encryptous/addCard2';
  const NewCardPage({super.key});
  @override
  State<NewCardPage> createState() => _NewCardPageState();
}

class _NewCardPageState extends State<NewCardPage> {
  String cardNumber = '';
  String _cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  GlobalKey<FormFieldState<String>>? cardNumberKey;
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  CardScanResul? _scanResult;
  TextEditingController _ocr = TextEditingController();
//This passage of code is
  /* void savedCardData(String cardNumber, String expiryDate,
      String cardHolderName, String cvvCode) async {
    final row = {
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'card_holder_name': cardHolderName,
      'cvv_code': cvvCode,
    };
    final id =
        await EncryptousHelper.instance.insertCard(row); //goes to database
    final allRows =
        await EncryptousHelper.instance.queryAllRows(); // prints to console
    print(allRows);

    print('Card saved with id: $id'); 
  }*/
  void savedCardData(String cardNumber, String expiryDate,
      String cardHolderName, String cvvCode) async {
    //final key = encrypt.AES()
    //final key = Key.fromUtf8('my secret key 123456');
    final key = encrypt.Key.fromUtf8(env.aes_private_key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final row = {
      'card_number': encrypter.encrypt(cardNumber, iv: iv).base64,
      'expiry_date': encrypter.encrypt(expiryDate, iv: iv).base64,
      'card_holder_name': encrypter.encrypt(cardHolderName, iv: iv).base64,
      'cvv_code': encrypter.encrypt(cvvCode, iv: iv).base64,
    };
    final id = await EncryptousHelper.instance.insertCard(row);
    final allRows = await EncryptousHelper.instance.queryAllRows();
    print(allRows);
    print('Card saved with id: $id');
  }

  //adds ocr technolology function by awaiting card scan
  void _startScan() async {
    CardScanResul? scanResult = await FlutterScanTools.scanCard(context);

    setState(() {
      _scanResult = scanResult;
      cardNumber = _scanResult!.cardNumber.number;
    });
    // onCreditCardModelChange(CreditCardModel(_scanResult!.cardNumber.number,
    //     expiryDate, cardHolderName, cvvCode, isCvvFocused));
    print(_scanResult);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Encryptous'),
      ),
      // All body code (e.g. widgets) go after body:

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            onCreditCardWidgetChange:
                (CreditCardBrand) {}, //true when you want to show cvv(back) view
          ),
          Expanded(
              flex: 1,
              child: CreditCardForm(
                formKey: formKey,
                obscureCvv: true,
                obscureNumber: true,
                cardNumber: _cardNumber,
                cardNumberKey: cardNumberKey,
                cvvCode: cvvCode,
                isHolderNameVisible: true,
                isCardNumberVisible: true,
                isExpiryDateVisible: true,
                cardHolderName: cardHolderName,
                expiryDate: expiryDate,
                themeColor: Colors.blue,
                textColor: Color.fromARGB(255, 0, 0, 0),
                cardNumberDecoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: 'XXXX XXXX XXXX XXXX',
                  hintStyle:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  focusedBorder: border,
                  enabledBorder: border,
                ),
                expiryDateDecoration: InputDecoration(
                  hintStyle:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  focusedBorder: border,
                  enabledBorder: border,
                  labelText: 'Expiry Date',
                  hintText: 'XX/XX',
                ),
                cvvCodeDecoration: InputDecoration(
                  hintStyle:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  focusedBorder: border,
                  enabledBorder: border,
                  labelText: 'CVV',
                  hintText: 'XXX',
                ),
                cardHolderDecoration: InputDecoration(
                  hintStyle:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  focusedBorder: border,
                  enabledBorder: border,
                  labelText: 'Card Holder Name',
                ),
                onCreditCardModelChange: onCreditCardModelChange,
              )),
          ElevatedButton(
            onPressed: () {
              _startScan();
              // try {
              //   print(cardNumberKey!.currentState);
              //   cardNumberKey!.currentState!.setValue(cardNumber);
              // } catch (e) {
              //   print("ERROR: $e \nCard Not entered");
              // }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            print(
                'Card saved: $cardNumber, $expiryDate, $cardHolderName, $cvvCode');

            savedCardData(cardNumber, expiryDate, cardHolderName, cvvCode);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card Details saved Succesfully')),
            );
            Navigator.pop(context);
          }
        },
        label: const Text('Save card'),
        icon: const Icon(Icons.save),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    print("Credit Card Model Change!");
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      _cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
