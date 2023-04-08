// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  static const routeName = '/Encryptous/login';
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String _currentPIN = '';
  bool _authenticated = false;

  Future<void> localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Please authenticate',
    );
    if (didAuthenticate) {
      Navigator.pop(context);
    }
  }

  Future<String?> getPIN() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentPIN = prefs.getString('current_pin');

    setState(() {
      _currentPIN = currentPIN ?? '';
    });
    return currentPIN;
  }

  Future<void> setPIN(String newPIN) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_pin', newPIN);

    setState(() {
      _currentPIN = newPIN;
    });
  }

  @override
  void initState() {
    super.initState();
    // localAuth(context, false);
  }

  @override
  Widget build(BuildContext context) {
    // if (!_authenticated) {
    //   return const SizedBox(
    //     child: Text(
    //       'Ya dun goof',
    //       style: TextStyle(color: Colors.white),
    //     ),
    //   );
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Passcode'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Define it to control the confirmation state with its own events.
                final controller = InputController();
                screenLockCreate(
                  context: context,
                  inputController: controller,
                  onConfirmed: (matchedText) {
                    Navigator.of(context).pop();

                    setPIN(controller.confirmedInput);
                    Navigator.pop(context); // Close dialog box
                  },
                  footer: TextButton(
                    onPressed: () {
                      //
                      // Release the confirmation state and return to the initial input state.
                      controller.unsetConfirmed();
                    },
                    child: const Text('Reset input'),
                  ),
                );
              },
              child: const Text('Confirm mode'),
            ),
          ],
        ),
      ),
    );
  }
}
