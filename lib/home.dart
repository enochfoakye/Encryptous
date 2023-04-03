import 'package:flutter/material.dart';
import 'package:my_app/add_new_card.dart';
import 'package:my_app/database.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'passcode.dart';

import 'env.dart' as env;

class HomePage extends StatefulWidget {
  static const routeName = '/Encryptous';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Encryptous'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: [
            ElevatedButton(
              onPressed: () {
                print('Hello Zaddy');
              },
              child: const Text('to Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, NewCardPage.routeName);
              },
              child: const Text('to add Card'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, LoginPage.routeName

                    //This is for the button pressed to navigate to the login page from home
                    );
              },
              child: const Text('to add User'),
            ),
            ElevatedButton(
              onPressed: () async {
                final rows = await EncryptousHelper.instance.queryAllRows();
                final key = encrypt.Key.fromUtf8(
                    env.aes_private_key); // Make this global
                final iv = encrypt.IV.fromLength(16);
                final encrypter = encrypt.Encrypter(encrypt.AES(key));

                for (final row in rows) {
                  print(row);
                  try {
                    final cardNumber =
                        encrypter.decrypt64(row['card_number'], iv: iv);
                    final expiryDate =
                        encrypter.decrypt64(row['expiry_date'], iv: iv);
                    final cardHolderName =
                        encrypter.decrypt64(row['card_holder_name'], iv: iv);
                    final cvvCode =
                        encrypter.decrypt64(row['cvv_code'], iv: iv);

                    print('Card Number: $cardNumber');
                    print('Expiry Date: $expiryDate');
                    print('Card Holder Name: $cardHolderName');
                    print('CVV Code: $cvvCode');
                    print('-------------------');
                  } catch (e) {
                    final cardNumber = "ERROR: $e";
                    final expiryDate = "ERROR: $e";
                    final cardHolderName = "ERROR: $e";
                    final cvvCode = "ERROR: $e";
                    print('Card Number: $cardNumber');
                    print('Expiry Date: $expiryDate');
                    print('Card Holder Name: $cardHolderName');
                    print('CVV Code: $cvvCode');
                    print('-------------------');
                  }
                }
              },
              child: const Text('Print all data'),
            ),
          ],
        ),
      ),
    );
  }
}
