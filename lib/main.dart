import 'package:flutter/material.dart';
import 'package:my_app/home.dart';
import 'package:my_app/passcode.dart';
import 'package:my_app/ocr.dart';

import 'package:my_app/add_new_card.dart';

import 'tester.dart';

void main() {
  runApp(const Encryptous());
}

class Encryptous extends StatelessWidget {
  const Encryptous({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        NewCardPage.routeName: (context) => const NewCardPage(),
        LoginPage.routeName: (context) => const LoginPage(),
        OcrPage.routeName: (context) => const OcrPage(),
        Tester.routeName: (context) => const Tester(),
      },
      home: const HomePage(),
    );
  }
}
