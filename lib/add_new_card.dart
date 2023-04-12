import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_scan_tools/flutter_scan_tools.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_app/passcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  //Creating Variables for the Credit Card form
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

  //Creates function that encrypts user input into form before storing into a databse
  void savedCardData(String cardNumber, String expiryDate,
      String cardHolderName, String cvvCode) async {
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

// to view credit card changes
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

  Future<void> localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Please authenticate',
    );
    if (didAuthenticate) {
      Navigator.pop(context);
      Navigator.pushNamed(context, AuthPage.routeName).then((_) => getPIN());
    }
  }

  String _currentPIN = '';

  Future<void> setPIN(String newPIN) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_pin', newPIN);

    setState(() {
      _currentPIN = newPIN;
    });
  }

  Future<String?> getPIN() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentPIN = prefs.getString('current_pin');

    setState(() {
      _currentPIN = currentPIN ?? '';
    });
    print("Current PIN: $_currentPIN");
    return currentPIN;
  }

  Future<void> _buildLockScreen(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ScreenLock(
            correctString: _currentPIN,
            customizedButtonChild: const Icon(Icons.fingerprint),
            customizedButtonTap: () async => await localAuth(context),
            onOpened: () async => await localAuth(context),
            onUnlocked: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AuthPage.routeName);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add New Card'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          //creates the card widget seen at the top of the form
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              isHolderNameVisible: true,
              onCreditCardWidgetChange:
                  (CreditCardBrand) {}, //true when you want to show cvv(back) view
            ),
            // creates the form underneath the card widget
            SingleChildScrollView(
                child: CreditCardForm(
              formKey: formKey,
              obscureCvv: false,
              obscureNumber: false,
              cardNumber: _cardNumber,
              cardNumberKey: cardNumberKey,
              cvvCode: cvvCode,
              isCardNumberVisible: true,
              isExpiryDateVisible: true,
              cardHolderName: cardHolderName,
              expiryDate: expiryDate,
              themeColor: Colors.blue,
              textColor: Color.fromARGB(255, 0, 0, 0),
              cardNumberDecoration: InputDecoration(
                labelText: 'Card Number',
                hintText: 'XXXX XXXX XXXX XXXX',
                hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                focusedBorder: border,
                enabledBorder: border,
              ),
              expiryDateDecoration: InputDecoration(
                hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                focusedBorder: border,
                enabledBorder: border,
                labelText: 'Expiry Date',
                hintText: 'XX/XX',
              ),
              cvvCodeDecoration: InputDecoration(
                hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                focusedBorder: border,
                enabledBorder: border,
                labelText: 'CVV',
                hintText: 'XXX',
              ),
              cardHolderDecoration: InputDecoration(
                hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                focusedBorder: border,
                enabledBorder: border,
                labelText: 'Card Holder Name',
              ),
              onCreditCardModelChange: onCreditCardModelChange,
            )),
            //Button for the ocr functunality
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
      ),

      //button to save user input and print to the console to check
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            // _buildLockScreen(context);
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
}

//First Fiunction created to save card
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
