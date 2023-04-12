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
  //Varaible for saving the passcode
  String _currentPIN = '';
  bool _authenticated = false;
  //creating function to use android authentication
  Future<void> localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Please authenticate',
    );
    if (didAuthenticate) {
      Navigator.pop(context);
      print(getPIN());
    }
  }

  //Using shared preferences to geet user input pin
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Passcode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(55, 71, 79, 1),
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
              child: const Text('Click Here to Change'),
            ),
          ],
        ),
      ),
    );
  }
}
