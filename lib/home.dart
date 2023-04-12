import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scan_tools/flutter_scan_tools.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_app/add_new_card.dart';
import 'package:my_app/database.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:my_app/passcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'env.dart' as env;
import 'package:flutter_credit_card/flutter_credit_card.dart';

//import 'tester.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/Encryptous';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  int _selectedIndex = 1;
  String _currentPIN = '';

  Future<String?> getPIN() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentPIN = prefs.getString('current_pin');

    setState(() {
      _currentPIN = currentPIN ?? '';
    });
    print("Current PIN: $_currentPIN");
    return currentPIN;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Chnage Passcode',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('HomePage',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('NewCard',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  @override
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  List<Map<String, dynamic>> _cards = [];
  void initState() {
    super.initState();
    getPIN(); //gets the current pin
    _loadCards(); //loads the cards when the app is loaded
  }

  Future<void> _loadCards() async {
    final cards = await EncryptousHelper.instance.queryAllRows();
    setState(() {
      _cards = cards;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encryptous'),
      ),
      body: Center(
        child: mainMenu(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.password),
                label: 'Change Password',
                backgroundColor: Colors.blue),
            BottomNavigationBarItem(
                icon: Icon(Icons.credit_card),
                label: 'Home',
                backgroundColor: Colors.red),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add New Card',
              backgroundColor: Colors.blue,
            ),
          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          iconSize: 40,
          onTap: _onItemTapped,
          elevation: 5),
    );
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
              Navigator.pushNamed(context, AuthPage.routeName).then((_) {
                getPIN();
              });
            },
          );
        });
  }

  Widget mainMenu(index) {
    //
    if (index == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(
                    55, 71, 79, 1), // Change background color to dark blue-grey
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      30), // Increase border radius to make it more rounded
                ),
                elevation: 6, // Reduce elevation to make it less 3D
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w600, // Use a slightly lighter font weight
                ),
              ),
              onPressed: () {
                _buildLockScreen(context);
              },
              child: const Text('CHANGE PASSCODE'),
            ),
          ),
        ],
      );
    } else if (index == 1) {
      // Middle button
      return Scaffold(
        body: _cards.isEmpty
            ? const Center(
                child: Text('No cards found'),
              )
            : ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  print(index);
                  final card = _cards[index];
                  final key = encrypt.Key.fromUtf8(env.aes_private_key);
                  final iv = encrypt.IV.fromLength(16);
                  final encrypter = encrypt.Encrypter(encrypt.AES(key));
                  final cardNumber =
                      encrypter.decrypt64(card['card_number'], iv: iv);
                  final expiryDate =
                      encrypter.decrypt64(card['expiry_date'], iv: iv);
                  final cardHolderName =
                      encrypter.decrypt64(card['card_holder_name'], iv: iv);
                  final cvvCode = encrypter.decrypt64(card['cvv_code'], iv: iv);

                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text('CVV Number'),
                            content: Text(cvvCode),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) async {
                        // Prompt user before deleting the card
                        final shouldDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                  "Are you sure you want to delete?"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: const Text("Delete"),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );
                        if (shouldDelete == true) {
                          final db = await EncryptousHelper.instance.database;
                          await db.delete(
                            'cards',
                            where: 'id = ?',
                            whereArgs: [card['id']],
                          );
                          _loadCards();
                        } else {
                          // Card deletion is cancelled
                          _loadCards();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CreditCardWidget(
                          cardNumber: cardNumber,
                          expiryDate: expiryDate,
                          cardHolderName: cardHolderName,
                          cvvCode: cvvCode,
                          showBackView: false,
                          obscureCardCvv: false,
                          obscureCardNumber: false,
                          isHolderNameVisible: true,
                          isSwipeGestureEnabled: true,
                          onCreditCardWidgetChange: (CreditCardBrand) {},
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, NewCardPage.routeName).then((_) {
              _loadCards();
            });
          },
          child: const Icon(Icons.add),
        ),
      );
    } else {
      return Scaffold(
        body: Column(
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
            Expanded(
                flex: 1,
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
            //Button for the ocr functunality
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    _startScan();
                  },
                  icon: Icon(Icons.camera_alt),
                  iconSize: 40,
                  color: Colors.blue,
                ),
                FloatingActionButton.extended(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      print(
                          'Card saved: $cardNumber, $expiryDate, $cardHolderName, $cvvCode');

                      savedCardData(
                          cardNumber, expiryDate, cardHolderName, cvvCode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Card Details saved Succesfully')),
                      );

                      Navigator.pushNamed(context, HomePage.routeName)
                          .then((_) {
                        _loadCards();
                      });
                    }
                  },
                  backgroundColor: Colors.blue,
                  label:
                      const Text('Save card', style: TextStyle(fontSize: 18)),
                  icon: const Icon(Icons.save),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}




// ToDo -ocr button into form field, When user Authentication is used passcode is not changed ,  move add card page to bottom nav

// String readSecretKeyFromFile() {
//   // Replace with the path to your secret key file
//   final file = File('C:/Users/enoch/OneDrive/Documents/test.txt');

//   if (!file.existsSync()) {
//     throw Exception('Secret key file does not exist');
//   }

//   return file.readAsStringSync().trim();
// }
