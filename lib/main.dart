import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_app/home.dart';

import 'package:my_app/ocr.dart';

import 'package:my_app/add_new_card.dart';
import 'package:my_app/passcode.dart';

import 'tester.dart';

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
        NewCardPage.routeName: (context) => const NewCardPage(),
        AuthPage.routeName: (context) => const AuthPage(),
        OcrPage.routeName: (context) => const OcrPage(),
      },
      home: const HomePage(),
    );
  }
}

// ToDo -ocr button into form field, When user Authentication is used passcode is not changed ,  have user confirm password after inputting data

// Future<void> _buildLockScreen(BuildContext context) {
//   return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return ScreenLock(
//           correctString: '1111',
//           customizedButtonChild: const Icon(Icons.fingerprint),
//           customizedButtonTap: () async => await localAuth(context),
//           onOpened: () async => await localAuth(context),
//           onUnlocked: () {
//             Navigator.pop(context);
//             Navigator.pushNamed(context, AuthPage.routeName);
//           },
//         );
//       });
// }



// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final localAuth = LocalAuthentication();
//   final didAuthenticate = await localAuth.authenticate(
//     localizedReason: 'Please authenticate',
//   );

//   if (didAuthenticate) {
//     runApp(const Encryptous());
//   } else {
//     SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
//   }

//   SystemChannels.lifecycle.setMessageHandler((msg) {
//     if (msg == AppLifecycleState.paused.toString()) {
//       localAuth
//           .authenticate(localizedReason: 'App restarted')
//           .then((isAuthenticated) {
//         if (!isAuthenticated) {
//           SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
//         }
//       });
//     }
//     return Future.value();
//   });
// }