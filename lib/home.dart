import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_app/add_new_card.dart';
import 'package:my_app/database.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:my_app/passcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'env.dart' as env;
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'tester.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/Encryptous';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  String _currentPIN = '';

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
    getPIN();
    // _showCards(); // you are here
  }

  Future<void> _loadCards() async {
    final cards = await EncryptousHelper.instance.queryAllRows();
    setState(() {
      _cards = cards;
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
    if (index == 0) {
      return Column(
        children: [
          ElevatedButton(
              child: const Text('CHANGE PASSCODE'),
              onPressed: () {
                _buildLockScreen(context);
                // Navigator.pushNamed(context, AuthPage.routeName);
              }
              //This is for the button pressed to navigate to the login page from home
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

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CreditCardWidget(
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: false,
                      onCreditCardWidgetChange: (CreditCardBrand) {},
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
    }
    return const Text('lol');
  }
}




// ToDo  - Sort out shared preferences page , name on the card, ocr button into form field 
