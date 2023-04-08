// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  static const routeName = '/Encryptous/login';
  const AuthPage({Key? key}) : super(key: key);

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

  // Future<void> localAuth(BuildContext context) async {
  //   // await getPIN();
  //   final localAuth = LocalAuthentication();
  //   final didAuthenticate =
  //       await localAuth.authenticate(localizedReason: 'Please authenticate');

  //   if (didAuthenticate) {
  //     setState(() {
  //       _authenticated = true;
  //     });
  //     Navigator.pop(context);

  //     //if (didAuthenticate) {
  //     //
  //   }
  // }

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
        title: Text('Passcode'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(context, builder) {
                  screenLock(
                    context: context,
                    correctString: _currentPIN,
                    customizedButtonChild: const Icon(Icons.fingerprint),
                    customizedButtonTap: () async => await localAuth(context),
                    onOpened: () async => await localAuth(context),
                    canCancel: false,
                  );
                }
              },
              child: const Text('Enter Passcode'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController _pinController =
                      TextEditingController();
                  return AlertDialog(
                    title: const Text('Set New Passcode'),
                    content: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter new passcode',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          setPIN(_pinController.text);
                          Navigator.pop(context); // Close dialog box
                          Navigator.pop(context); // Return to homescreen
                        },
                        child: const Text('SAVE'),
                      ),
                    ],
                  );
                },
              ),
              child: const Text('Set New Passcode'),
            ),
            ElevatedButton(
              onPressed: () {
                // Define it to control the confirmation state with its own events.
                final controller = InputController();
                screenLockCreate(
                  context: context,
                  inputController: controller,
                  onConfirmed: (matchedText) => Navigator.of(context).pop(),
                  footer: TextButton(
                    onPressed: () {
                      // Release the confirmation state and return to the initial input state.
                      controller.unsetConfirmed();
                    },
                    child: const Text('Reset input'),
                  ),
                );
              },
              child: const Text('Confirm mode'),
            ),
            ElevatedButton(
              onPressed: () => screenLock(
                context: context,
                correctString: '1234',
                customizedButtonChild: const Icon(
                  Icons.fingerprint,
                ),
                customizedButtonTap: () async => await localAuth(context),
                onOpened: () async => await localAuth(context),
              ),
              child: const Text(
                'use local_auth \n(Show local_auth when opened)',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
