import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_app/home.dart';
import 'package:my_app/passcode.dart';

//User authenticate before app is launched
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localAuth = LocalAuthentication();
  final didAuthenticate = await localAuth.authenticate(
    localizedReason: 'Please authenticate',
  );
  if (didAuthenticate) {
    runApp(const Encryptous());
  }
}

class Encryptous extends StatelessWidget {
  const Encryptous({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        AuthPage.routeName: (context) => const AuthPage(),
      },
      home: const HomePage(),
    );
  }
}
