import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/Encryptous/login';
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _currentPIN = '';

  Future<String?> getPIN() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentPIN = prefs.getString('current_pin');

    setState(() {
      _currentPIN = currentPIN!;
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

  Future<void> localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate =
        await localAuth.authenticate(localizedReason: 'Please authenticate');
    if (didAuthenticate) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    getPIN();
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => screenLock(
                context: context,
                correctString: _currentPIN,
                customizedButtonChild: const Icon(Icons.fingerprint),
                customizedButtonTap: () async => await localAuth(context),
                onOpened: () async => await localAuth(context),
                canCancel: false,
              ),
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
                          Navigator.pop(context);
                        },
                        child: const Text('SAVE'),
                      ),
                    ],
                  );
                },
              ),
              child: const Text('Set New Passcode'),
            ),
          ],
        ),
      ),
    );
  }
}
